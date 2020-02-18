# resource "datadog_user" "Martin_smith" {
#   email       = "msmith@hashicorp1.com"
#   handle      = "msmith@hashicorp1.com"
#   name        = "Martin_smith"
#   access_role = "adm"
# }

# resource "datadog_user" "matt_mcquillan" {
#   email       = "matt@hashicorp1.com"
#   handle      = "matt@hashicorp1.com"
#   name        = "Matt McQuillan"
#   access_role = "adm"
# }

# resource "datadog_user" "will_bengston" {
#   email       = "wbengtson@hashicorp1.com"
#   handle      = "wbengtson@hashicorp1.com"
#   name        = "Will Bengston"
#   access_role = "st"
# }

# resource "datadog_user" "zack_iles" {
#   email       = "zack.iles@hashicorp1.com"
#   handle      = "zack.iles@hashicorp1.com"
#   name        = "Zack Iles"
#   access_role = "st"
# }

resource "datadog_user" "adm_users" {
  for_each = var.adm_users
  name = each.value.name
  email = each.value.email
  handle = each.value.handler
  access_role = "adm"
}

resource "datadog_user" "st_users" {
  for_each = var.st_users
  name = each.value.name
  email = each.value.email
  handle = each.value.handler
  access_role = "st"
}
# Not really creating these. They are constructed automatically 
# resource "datadog_logs_integration_pipeline" "integrations" {
#     for_each = var.integrations
#     is_enabled = true
# }

resource "datadog_logs_custom_pipeline" "custom_pipelines" {
  for_each = var.custom_pipelines
  dynamic "filter"{
    for_each = [for filter in custom_pipelines.filter: {
      query = filter.query
    }]
  }
  # filter = each.value.filter
  # name = each.value.name
  # is_enabled = true
  # processor = each.value.processor
}