resource "datadog_user" "alex_podobnik" {
  count       = local.env == "prod" ? 1 : 0
  email       = "apodobnik@hashicorp.com"
  handle      = "apodobnik@hashicorp.com"
  name        = "Alex Podobnik"
  access_role = "adm"
}