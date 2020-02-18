custom_pipelines = {
  "cadence-worker, cadence-shared" = {
    filter = {
      query = "service:(cloud-cadence-worker OR cloud-cadence-shared)"
    }
    processor = {
      type = "pipeline"
      name = "Terraform"
      is_enabled = "false"
      filter = {
        query = "@msg:\"terraform output\""
      }
    }
    processor = {
      type = "string-builder-processor"
      name = "terraform output: %%{line} - in attribute prefixed_line"
      is_enabled = "true"
      template = "terraform output: %%{line}"
      target = "prefixed_line"
    }
  }
}