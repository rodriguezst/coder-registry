---
display_name: OpenCode
description: Run OpenCode AI coding agent in your workspace
icon: ../../../../.icons/opencode.svg
maintainer_github: coder
verified: true
tags: [agent, opencode, ai, tasks, provider-agnostic]
---

# OpenCode

Run the [OpenCode](https://opencode.ai) AI coding agent in your workspace to generate code and perform tasks. OpenCode is an open-source, provider-agnostic coding agent that works with multiple AI providers including Anthropic, OpenAI, and Google.

```tf
module "opencode" {
  source           = "registry.coder.com/coder/opencode/coder"
  version          = "1.0.0"
  agent_id         = coder_agent.example.id
  folder           = "/home/coder"
  install_opencode = true
  opencode_version = "latest"
  ai_provider      = "anthropic"
}
```

## Prerequisites

- Node.js and npm must be installed in your workspace to install OpenCode
- You must add the [Coder Login](https://registry.coder.com/modules/coder-login) module to your template
- API keys for your chosen AI provider(s) must be configured via environment variables

The `codercom/oss-dogfood:latest` container image can be used for testing on container-based workspaces.

## Examples

### Run with Anthropic Claude (default)

```tf
variable "anthropic_api_key" {
  type        = string
  description = "The Anthropic API key"
  sensitive   = true
}

module "coder-login" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/coder-login/coder"
  version  = "1.0.15"
  agent_id = coder_agent.example.id
}

data "coder_parameter" "ai_prompt" {
  type        = "string"
  name        = "AI Prompt"
  default     = ""
  description = "Write a prompt for OpenCode"
  mutable     = true
}

# Set the prompt and API key for OpenCode via environment variables
resource "coder_agent" "main" {
  # ...
  env = {
    ANTHROPIC_API_KEY              = var.anthropic_api_key
    CODER_MCP_OPENCODE_TASK_PROMPT = data.coder_parameter.ai_prompt.value
    CODER_MCP_APP_STATUS_SLUG      = "opencode"
  }
}

module "opencode" {
  count            = data.coder_workspace.me.start_count
  source           = "registry.coder.com/coder/opencode/coder"
  version          = "1.0.0"
  agent_id         = coder_agent.example.id
  folder           = "/home/coder"
  install_opencode = true
  opencode_version = "latest"
  ai_provider      = "anthropic"

  # Enable experimental features
  experiment_report_tasks = true
}
```

### Run with OpenAI

```tf
variable "openai_api_key" {
  type        = string
  description = "The OpenAI API key"
  sensitive   = true
}

resource "coder_agent" "main" {
  # ...
  env = {
    OPENAI_API_KEY                 = var.openai_api_key
    CODER_MCP_OPENCODE_TASK_PROMPT = data.coder_parameter.ai_prompt.value
    CODER_MCP_APP_STATUS_SLUG      = "opencode"
  }
}

module "opencode" {
  count                   = data.coder_workspace.me.start_count
  source                  = "registry.coder.com/coder/opencode/coder"
  version                 = "1.0.0"
  agent_id                = coder_agent.example.id
  folder                  = "/home/coder"
  ai_provider             = "openai"
  experiment_report_tasks = true
}
```

### Run with Google AI

```tf
variable "google_ai_api_key" {
  type        = string
  description = "The Google AI API key"
  sensitive   = true
}

resource "coder_agent" "main" {
  # ...
  env = {
    GOOGLE_AI_API_KEY              = var.google_ai_api_key
    CODER_MCP_OPENCODE_TASK_PROMPT = data.coder_parameter.ai_prompt.value
    CODER_MCP_APP_STATUS_SLUG      = "opencode"
  }
}

module "opencode" {
  count                   = data.coder_workspace.me.start_count
  source                  = "registry.coder.com/coder/opencode/coder"
  version                 = "1.0.0"
  agent_id                = coder_agent.example.id
  folder                  = "/home/coder"
  ai_provider             = "google"
  experiment_report_tasks = true
}
```

## Run standalone

Run OpenCode as a standalone app in your workspace. This will install OpenCode and run it without any task reporting to the Coder UI.

```tf
module "opencode" {
  source           = "registry.coder.com/coder/opencode/coder"
  version          = "1.0.0"
  agent_id         = coder_agent.example.id
  folder           = "/home/coder"
  install_opencode = true
  opencode_version = "latest"
  ai_provider      = "anthropic"

  # Use a custom icon URL if needed
  icon = "https://example.com/opencode-icon.png"
}
```

## AI Provider Configuration

OpenCode supports multiple AI providers. Configure the appropriate API key environment variable:

| Provider  | Environment Variable | Description             |
| --------- | -------------------- | ----------------------- |
| Anthropic | `ANTHROPIC_API_KEY`  | Claude models (default) |
| OpenAI    | `OPENAI_API_KEY`     | GPT models              |
| Google    | `GOOGLE_AI_API_KEY`  | Gemini models           |

## Variables

| Name                      | Type     | Default              | Description                                        |
| ------------------------- | -------- | -------------------- | -------------------------------------------------- |
| `agent_id`                | `string` |                      | The ID of a Coder agent                            |
| `folder`                  | `string` | `/home/coder`        | The folder to run OpenCode in                      |
| `install_opencode`        | `bool`   | `true`               | Whether to install OpenCode                        |
| `opencode_version`        | `string` | `latest`             | The version of OpenCode to install                 |
| `ai_provider`             | `string` | `anthropic`          | The AI provider to use (anthropic, openai, google) |
| `install_agentapi`        | `bool`   | `true`               | Whether to install AgentAPI                        |
| `agentapi_version`        | `string` | `v0.2.2`             | The version of AgentAPI to install                 |
| `experiment_report_tasks` | `bool`   | `false`              | Whether to enable task reporting                   |
| `experiment_cli_app`      | `bool`   | `false`              | Whether to create the CLI workspace app            |
| `icon`                    | `string` | `/icon/opencode.svg` | The icon to use for the app                        |
| `order`                   | `number` | `null`               | The order determines the position of app in the UI |
| `group`                   | `string` | `null`               | The name of a group that this app belongs to       |

## Troubleshooting

The module will create log files in the workspace's `~/.opencode-module` directory. If you run into any issues, look at them for more information.

### Common Issues

1. **Missing API Key**: Ensure the correct environment variable is set for your chosen AI provider
2. **Node.js Issues**: The module will attempt to install Node.js via NVM if not present
3. **AgentAPI Connection**: Check that port 3284 is available and not blocked by firewalls
4. **Provider Configuration**: Verify your chosen AI provider supports the models you want to use

### Logs

- Main installation log: Check the Coder script logs in the UI
- AgentAPI logs: `~/.opencode-module/agentapi.log`
- Startup logs: `~/.opencode-module/agentapi-start.log`
