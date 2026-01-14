---
display_name: Selkies Desktop
description: Stream and access remote Linux desktops using Selkies-GStreamer
icon: ../../../../.icons/vnc.svg
maintainer_github: coder
verified: true
tags: [selkies, desktop, streaming]
---

# Selkies Desktop

Automatically install [Selkies-GStreamer](https://selkies.io/) in a workspace, and create an app to access it via the dashboard.

```tf
module "selkies" {
  count               = data.coder_workspace.me.start_count
  source              = "registry.coder.com/coder/selkies/coder"
  # version = "1.0.0"
  agent_id            = coder_agent.example.id
  # Selkies does not require desktop_environment option
  subdomain           = true
}
```

> **Note:** Requires X11 desktop and PulseAudio; see [Selkies quick start docs](https://selkies-project.github.io/selkies/start/#quick-start) for setup.
