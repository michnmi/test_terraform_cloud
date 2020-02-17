variable "datadog_api_key" {}
variable "testing_datadog_api" {}


variable "user_names" {
    description = "Create datadog users with these names"
    type = list(string)
    default = ["MM", "MS", "MP"]
}