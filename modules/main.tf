resource "datadog_user" "alex_podobnik" {
  email       = "michalis@hashicorp.com"
  handle      = "michalis@hashicorp.com"
  name        = "MM"
  access_role = "adm"
}

resource "datadog_user" "Testing you can ignore me" {
  email       = "msmith@hashicorp.com"
  handle      = "msmith@hashicorp.com"
  name        = "msmith@hashicorp.com"
  access_role = "adm"
}
