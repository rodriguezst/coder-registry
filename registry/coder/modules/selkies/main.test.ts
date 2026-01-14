import { describe, expect, it } from "bun:test";
import {
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "~test";

const allowedDesktopEnvs = ["xfce", "kde", "gnome", "lxde", "lxqt"] as const;
type AllowedDesktopEnv = (typeof allowedDesktopEnvs)[number];

type TestVariables = Readonly<{
  agent_id: string;
  # desktop_environment not required for Selkies
  port?: string;
  selkies_version?: string;
}>;

describe("Selkies Desktop", async () => {
  await runTerraformInit(import.meta.dir);
  testRequiredVariables<TestVariables>(import.meta.dir, {
    agent_id: "foo",
    desktop_environment: "gnome",
  });

  it("Successfully installs for all expected Kasm desktop versions", async () => {
    const testVars = {
      agent_id: "foo",
      selkies_version: "latest"
    };
    runTerraformApply<TestVariables>(import.meta.dir, testVars);
      const applyWithEnv = () => {
        runTerraformApply<TestVariables>(import.meta.dir, {
          agent_id: "foo",
          desktop_environment: v,
        });
      };

      expect(applyWithEnv).not.toThrow();
    }
  });
});
