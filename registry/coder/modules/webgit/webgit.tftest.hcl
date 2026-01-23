run "required_vars" {
  command = plan

  variables {
    agent_id = "foo"
  }
}

run "custom_port" {
  command = plan

  variables {
    agent_id = "foo"
    port     = 8080
  }

  assert {
    condition     = resource.coder_app.webgit.url == "http://localhost:8080"
    error_message = "coder_app URL must match custom port"
  }
}

run "custom_directory" {
  command = plan

  variables {
    agent_id  = "foo"
    directory = "/home/coder/my-repo"
  }
}

run "wait_for_node_disabled" {
  command = plan

  variables {
    agent_id      = "foo"
    wait_for_node = false
  }
}

run "subdomain_false" {
  command = plan

  variables {
    agent_id   = "foo"
    agent_name = "main"
    subdomain  = false
  }
}

run "custom_slug" {
  command = plan

  variables {
    agent_id = "foo"
    slug     = "git-viewer"
  }

  assert {
    condition     = resource.coder_app.webgit.slug == "git-viewer"
    error_message = "coder_app slug must match custom value"
  }
}

run "invalid_share_value" {
  command = plan

  variables {
    agent_id = "foo"
    share    = "invalid"
  }

  expect_failures = [
    var.share
  ]
}
