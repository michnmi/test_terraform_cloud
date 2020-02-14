# Configure the Datadog provider
provider "datadog" {
  version = "~> 2.5"
  api_key = var.datadog_api_key
  app_key = var.testing_datadog_api
  api_url = "https://api.datadoghq.eu/api/"
}

provider "aws" {
    region = "eu-west-1"
}
