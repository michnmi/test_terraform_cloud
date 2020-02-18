variable "datadog_api_key" {}
variable "testing_datadog_api" {}

variable "adm_users" { 
    type = map
}

variable "st_users" {
    type = map
}
variable "integrations" {
    type = set(string)
}