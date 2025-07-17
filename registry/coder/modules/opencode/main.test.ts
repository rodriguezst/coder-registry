import {
  test,
  afterEach,
  expect,
  describe,
  setDefaultTimeout,
  beforeAll,
} from "bun:test";
import path from "path";
import {
  execContainer,
  findResourceInstance,
  removeContainer,
  runContainer,
  runTerraformApply,
  runTerraformInit,
  writeCoder,
  writeFileContainer,
} from "~test";

let cleanupFunctions: (() => Promise<void>)[] = [];

const registerCleanup = (cleanup: () => Promise<void>) => {
  cleanupFunctions.push(cleanup);
};

// Cleanup logic depends on the fact that bun's built-in test runner
// runs tests sequentially.
// https://bun.sh/docs/test/discovery#execution-order
// Weird things would happen if tried to run tests in parallel.
// One test could clean up resources that another test was still using.
afterEach(async () => {
  // reverse the cleanup functions so that they are run in the correct order
  const cleanupFnsCopy = cleanupFunctions.slice().reverse();
  cleanupFunctions = [];
  for (const cleanup of cleanupFnsCopy) {
    try {
      await cleanup();
    } catch (error) {
      console.error("Error during cleanup:", error);
    }
  }
});

const setupContainer = async ({
  image,
  vars,
}: {
  image?: string;
  vars?: Record<string, string>;
}) => {
  const containerID = await runContainer(
    image ?? "codercom/oss-dogfood:latest",
  );
  registerCleanup(() => removeContainer(containerID));

  await writeFileContainer(
    containerID,
    "/tmp/main.tf",
    `
    terraform {
      required_providers {
        coder = {
          source = "coder/coder"
          version = "~> 2.18"
        }
      }
    }

    resource "coder_agent" "main" {
      os             = "linux"
      arch           = "amd64"
      startup_script = ""
      env = {
        ANTHROPIC_API_KEY = "test-key"
        CODER_MCP_OPENCODE_TASK_PROMPT = "test prompt"
        CODER_MCP_APP_STATUS_SLUG = "opencode"
      }
    }

    module "opencode" {
      source = "/tmp/module"
      agent_id = coder_agent.main.id
      ${Object.entries(vars ?? {})
        .map(([key, value]) => `${key} = ${JSON.stringify(value)}`)
        .join("\n      ")}
    }
    `,
  );

  await execContainer(containerID, ["cp", "-r", "/tmp/inputs", "/tmp/module"]);

  await runTerraformInit(containerID, "/tmp");
  return containerID;
};

setDefaultTimeout(300_000);

beforeAll(async () => {
  await writeCoder({
    build: "/tmp/outputs",
    module: path.join(__dirname),
  });
});

describe("opencode module", () => {
  test("basic installation", async () => {
    const containerID = await setupContainer({});

    const result = await runTerraformApply(containerID, "/tmp");
    expect(result.exitCode).toBe(0);

    // Check that the module was configured correctly
    const agentScript = findResourceInstance(
      result.resources,
      "coder_script",
      "opencode",
    );
    expect(agentScript).toBeDefined();
    expect(agentScript.attributes.display_name).toBe("OpenCode");

    // Check that the web app was created
    const webApp = findResourceInstance(
      result.resources,
      "coder_app",
      "opencode_web",
    );
    expect(webApp).toBeDefined();
    expect(webApp.attributes.display_name).toBe("OpenCode Web");
    expect(webApp.attributes.url).toBe("http://localhost:3284/");

    // Check that the AI task was created
    const aiTask = findResourceInstance(
      result.resources,
      "coder_ai_task",
      "opencode",
    );
    expect(aiTask).toBeDefined();
  });

  test("with custom configuration", async () => {
    const containerID = await setupContainer({
      vars: {
        folder: "/workspace",
        opencode_version: "0.0.5",
        ai_provider: "openai",
        experiment_report_tasks: true,
      },
    });

    const result = await runTerraformApply(containerID, "/tmp");
    expect(result.exitCode).toBe(0);

    const agentScript = findResourceInstance(
      result.resources,
      "coder_script",
      "opencode",
    );
    expect(agentScript.attributes.script).toContain("/workspace");
    expect(agentScript.attributes.script).toContain("opencode-ai@0.0.5");
  });

  test("with CLI app enabled", async () => {
    const containerID = await setupContainer({
      vars: {
        experiment_cli_app: true,
        experiment_cli_app_order: 1,
        experiment_cli_app_group: "AI Tools",
      },
    });

    const result = await runTerraformApply(containerID, "/tmp");
    expect(result.exitCode).toBe(0);

    // Check that the CLI app was created
    const cliApp = findResourceInstance(
      result.resources,
      "coder_app",
      "opencode",
    );
    expect(cliApp).toBeDefined();
    expect(cliApp.attributes.display_name).toBe("OpenCode CLI");
    expect(cliApp.attributes.order).toBe(1);
    expect(cliApp.attributes.group).toBe("AI Tools");
  });

  test("ai_provider validation", async () => {
    const containerID = await setupContainer({
      vars: {
        ai_provider: "invalid_provider",
      },
    });

    const result = await runTerraformApply(containerID, "/tmp");
    expect(result.exitCode).not.toBe(0);
    expect(result.stderr).toContain(
      "AI provider must be one of: anthropic, openai, google",
    );
  });
});
