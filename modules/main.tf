resource "datadog_user" "alex_podobnik" {
  email       = "michalis@hashicorp.com"
  handle      = "michalis@hashicorp.com"
  name        = "MM"
  access_role = "adm"
}

resource "datadog_user" "Martin_smith" {
  email       = "msmith@hashicorp.com"
  handle      = "msmith@hashicorp.com"
  name        = "msmith@hashicorp.com"
  access_role = "adm"
}
