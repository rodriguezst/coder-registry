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

data "coder_workspace" "me" {}

data "coder_workspace_owner" "me" {}

variable "agent_name" {
  type        = string
  description = "The name of the coder_agent resource. (Only required if subdomain is false and the template uses multiple agents.)"
  default     = null
}

variable "log_path" {
  type        = string
  description = "The path to log webgit to."
  default     = "/tmp/webgit.log"
}

variable "port" {
  type        = number
  description = "The port to run webgit on."
  default     = 3000
}

variable "directory" {
  type        = string
  description = "The path to the git repository to serve. Defaults to the home directory."
  default     = "~"
}

variable "share" {
  type    = string
  default = "owner"
  validation {
    condition     = var.share == "owner" || var.share == "authenticated" || var.share == "public"
    error_message = "Incorrect value. Please set either 'owner', 'authenticated', or 'public'."
  }
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

variable "slug" {
  type        = string
  description = "The slug of the coder_app resource."
  default     = "webgit"
}

variable "subdomain" {
  type        = bool
  description = <<-EOT
    Determines whether the app will be accessed via it's own subdomain or whether it will be accessed via a path on Coder.
    If wildcards have not been setup by the administrator then apps with "subdomain" set to true will not be accessible.
  EOT
  default     = true
}

variable "wait_for_node" {
  type        = bool
  description = "Whether to wait for node and npm to be available before starting webgit. Enable this if node/npm is installed by another module."
  default     = true
}

variable "node_wait_timeout" {
  type        = number
  description = "Maximum time in seconds to wait for node and npm to be available."
  default     = 300
}

resource "coder_script" "webgit" {
  agent_id     = var.agent_id
  display_name = "Webgit"
  icon         = "/icon/git.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port,
    DIRECTORY : var.directory,
    WAIT_FOR_NODE : var.wait_for_node,
    NODE_WAIT_TIMEOUT : var.node_wait_timeout
  })
  run_on_start = true
}

resource "coder_app" "webgit" {
  agent_id     = var.agent_id
  slug         = var.slug
  display_name = "Webgit"
  url          = local.url
  icon         = "/icon/git.svg"
  subdomain    = var.subdomain
  share        = var.share
  order        = var.order
  group        = var.group

  healthcheck {
    url       = local.healthcheck_url
    interval  = 5
    threshold = 6
  }
}

locals {
  server_base_path = var.subdomain ? "" : format("/@%s/%s%s/apps/%s", data.coder_workspace_owner.me.name, data.coder_workspace.me.name, var.agent_name != null ? ".${var.agent_name}" : "", var.slug)
  url              = "http://localhost:${var.port}${local.server_base_path}"
  healthcheck_url  = "http://localhost:${var.port}${local.server_base_path}/"
}
