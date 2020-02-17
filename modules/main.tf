resource "datadog_user" "Martin_smith" {
  email       = "msmith@hashicorp1.com"
  handle      = "msmith@hashicorp1.com"
  name        = "Martin_smith"
  access_role = "adm"
}

resource "datadog_user" "will_bengston" {
  count       = local.env == "prod" ? 1 : 0
  email       = "wbengtson@hashicorp1.com"
  handle      = "wbengtson@hashicorp1.com"
  name        = "Will Bengston"
  access_role = "st"
}

resource "datadog_user" "zack_iles" {
  count       = local.env == "prod" ? 1 : 0
  email       = "zack.iles@hashicorp1.com"
  handle      = "zack.iles@hashicorp1.com"
  name        = "Zack Iles"
  access_role = "st"
}

resource "datadog_user" "matt_mcquillan" {
  count       = local.env == "prod" ? 1 : 0
  email       = "matt@hashicorp1.com"
  handle      = "matt@hashicorp1.com"
  name        = "Matt McQuillan"
  access_role = "adm"
}
