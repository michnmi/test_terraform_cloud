variable "datadog_api_key" {}
variable "testing_datadog_api" {}

# variable "adm_users" {
#     type = map(object({
#         name = string
#         email = string
#         handler = string
#     }))
#     description = "Admin user created by Terraform. Do not edit manually"
# }

variable "adm_users" { 
    type = "map"
    default = {
        name = string
        email = string
        handler = string
    }
}

variable "st_users" {
    type = map(object({
        name = string
        email = string
        handler = string
    }))
    description = "ST user created by Terraform. Do not edit manually"
}