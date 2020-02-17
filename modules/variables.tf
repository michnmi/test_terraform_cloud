variable "datadog_api_key" {}
variable "testing_datadog_api" {}

variable "adm_users" {
    type = map(object({
        name = string
        email = string
        handler = string
        access_role = string
    }))
    description = "Admin user created by Terraform. Do not edit manually"
}
