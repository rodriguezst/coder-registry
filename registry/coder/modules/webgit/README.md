---
display_name: Webgit
description: A standalone Git viewer web client for browsing repositories
icon: ../../../../.icons/git.svg
verified: false
tags: [git, web, viewer, repository]
---

# Webgit

A standalone Git viewer web client that allows you to browse your git repositories from the browser. Powered by [@rodriguezst\_/webgit](https://www.npmjs.com/package/@rodriguezst_/webgit).

```tf
module "webgit" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/webgit/coder"
  version  = "1.0.0"
  agent_id = coder_agent.main.id
}
```

## Prerequisites

This module requires Node.js and npm to be installed. If you're using another module to install Node.js (like a node module), you should ensure it runs before this module, or use the `wait_for_node` option.

## Examples

### Basic usage with default settings

```tf
module "webgit" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/webgit/coder"
  version  = "1.0.0"
  agent_id = coder_agent.main.id
}
```

### Serve a specific git repository

```tf
module "webgit" {
  count     = data.coder_workspace.me.start_count
  source    = "registry.coder.com/coder/webgit/coder"
  version   = "1.0.0"
  agent_id  = coder_agent.main.id
  directory = "/home/coder/my-project"
}
```

### Use with node module (wait for node to be installed)

```tf
module "node" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/node/coder"
  version  = "1.0.0"
  agent_id = coder_agent.main.id
}

module "webgit" {
  count             = data.coder_workspace.me.start_count
  source            = "registry.coder.com/coder/webgit/coder"
  version           = "1.0.0"
  agent_id          = coder_agent.main.id
  wait_for_node     = true
  node_wait_timeout = 300
  depends_on        = [module.node]
}
```

### Custom port and disable node wait

```tf
module "webgit" {
  count         = data.coder_workspace.me.start_count
  source        = "registry.coder.com/coder/webgit/coder"
  version       = "1.0.0"
  agent_id      = coder_agent.main.id
  port          = 8080
  wait_for_node = false
}
```

### Serve from the same domain (no subdomain)

```tf
module "webgit" {
  count      = data.coder_workspace.me.start_count
  source     = "registry.coder.com/coder/webgit/coder"
  version    = "1.0.0"
  agent_id   = coder_agent.main.id
  agent_name = "main"
  subdomain  = false
}
```

## Features

- Browse git repositories in a web interface
- View commits, branches, and tags
- Explore file history
- Automatically waits for Node.js/npm if needed
- Configurable port and directory
- Subdomain or path-based access

## Variables

- `agent_id` (required): The ID of a Coder agent
- `agent_name`: The name of the coder_agent resource (only required if subdomain is false and multiple agents)
- `directory`: Path to the git repository (default: `~`)
- `port`: Port to run webgit on (default: `3000`)
- `log_path`: Path to log file (default: `/tmp/webgit.log`)
- `subdomain`: Access via subdomain or path (default: `true`)
- `wait_for_node`: Wait for node/npm to be available (default: `true`)
- `node_wait_timeout`: Maximum wait time in seconds for node/npm (default: `300`)
- `share`: Share setting - "owner", "authenticated", or "public" (default: `owner`)
- `order`: Position in UI presentation
- `group`: Group name for the app
- `slug`: The slug for the app (default: `webgit`)
