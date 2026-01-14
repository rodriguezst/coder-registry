terraform {
  required_version = ">= 1.0"
  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.5"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "port" {
  type        = number
  description = "The port to run Selkies Desktop on."
  default     = 6800
}

variable "selkies_version" {
  type        = string
  description = "Version of Selkies-GStreamer to install (latest recommended)."
  default     = "latest"
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

variable "group" {
  type        = string
  description = "The name of a group that this app belongs to."
  default     = null
}



resource "coder_script" "selkies_desktop" {
  agent_id     = var.agent_id
  display_name = "Selkies Desktop"
  icon         = "/icon/vnc.svg"
  run_on_start = true
  script = templatefile("${path.module}/run.sh", {
    PORT            = var.port
    SELKIES_VERSION = var.selkies_version
  })
}

resource "coder_app" "selkies_desktop" {
  agent_id     = var.agent_id
  slug         = "selkies-desktop"
  display_name = "Selkies Desktop"
  url          = "http://localhost:${var.port}"
  icon         = "/icon/vnc.svg"
  share        = "owner"
  order        = var.order
  group        = var.group

  healthcheck {
    url       = "http://localhost:${var.port}/"
    interval  = 5
    threshold = 5
  }
}
