resource "datadog_user" "Martin_smith" {
  email       = "msmith@hashicorp.com"
  handle      = "msmith@hashicorp.com"
  name        = "msmith@hashicorp.com"
  access_role = "adm"
}


resource "datadog_user" "admin_users" {
  count = length(var.user_names)
  name = var.user_names[count.index]
}

