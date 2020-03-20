# resource "datadog_user" "Martin_smith" {
#   email       = "msmith@hashicorp1.com"
#   handle      = "msmith@hashicorp1.com"
#   name        = "Martin_smith"
#   access_role = "adm"
# }

# resource "datadog_user" "matt_mcquillan" {
#   email       = "matt@hashicorp1.com"
#   handle      = "matt@hashicorp1.com"
#   name        = "Matt McQuillan"
#   access_role = "adm"
# }

# resource "datadog_user" "will_bengston" {
#   email       = "wbengtson@hashicorp1.com"
#   handle      = "wbengtson@hashicorp1.com"
#   name        = "Will Bengston"
#   access_role = "st"
# }

# resource "datadog_user" "zack_iles" {
#   email       = "zack.iles@hashicorp1.com"
#   handle      = "zack.iles@hashicorp1.com"
#   name        = "Zack Iles"
#   access_role = "st"
# }

# resource "datadog_user" "adm_users" {
#   for_each = var.adm_users
#   name = each.value.name
#   email = each.value.email
#   handle = each.value.handler
#   access_role = "adm"
# }

# resource "datadog_user" "st_users" {
#   for_each = var.st_users
#   name = each.value.name
#   email = each.value.email
#   handle = each.value.handler
#   access_role = "st"
# }
# Not really creating these. They are constructed automatically 
# resource "datadog_logs_integration_pipeline" "integrations" {
#     for_each = var.integrations
#     is_enabled = true
# }

# resource "datadog_logs_custom_pipeline" "cadence_worker-cadence_shared" {
#   filter {
#     query = "service:(cloud-cadence-worker OR cloud-cadence-shared)"
#   }
#   name = "cadence-worker, cadence-shared"
#   is_enabled = true
#   processor {
#     pipeline {
#       name = "Terraform"
#       is_enabled = false
#       filter {
#         query = "@msg:\"terraform output\""
#       }
#       processor {
#         string_builder_processor {
#           target = "prefixed_line"
#           template = "terraform output: %%{line}"
#           name = "terraform output: %%{line} - in attribute prefixed_line"
#           is_enabled = true
#           is_replace_missing = true
#         }
#         message_remapper {
#           sources = ["prefixed_line"]
#           name = "Output Line"
#           is_enabled = true
#         }
#       }
#     }

#   }

# }
resource "datadog_logs_custom_pipeline" "cadence-worker_cadence-shared" {
    filter {
        query = "service:(cloud-cadence-worker OR cloud-cadence-shared)"
    }
    name = "cadence-worker, cadence-shared"
    is_enabled = true
    processor {
        pipeline {
            filter {
                query = "@msg:\"terraform output\""
            }
            is_enabled = false
            name = "Terraform"
        }
        processor {
            string_builder_processor {
                target = "prefixed_line"
                is_replace_missing = true
                is_enabled = true
                template = "terraform output: %%{line}"
                name = "terraform output: %%{line} - in attribute prefixed_line"
            }
        }
        processor {
            message_remapper {
                sources = ["prefixed_line"]
                is_enabled = true
                name = "Output Line"
            }
        }
    }
    processor {
        message_remapper {
            sources = ["msg"]
            is_enabled = true
            name = "Message Attribute (msg)"
        }
    }
    processor {
        grok_parser {
            samples = ["2019-12-19T12:58:39.895Z [WARN]  interrupt received, shutting down"]
            source = "message"
            is_enabled = true
            grok {
                support_rules = ""
                match_rules = "Rule %%{date(\"yyyy-MM-dd'T'HH:mm:ss.SSSZ\"):date} \\[%%{word:level}\\] +%%{data:msg}"
            }
            name = "Parse unmatched plaintext logs"
        }
    }
    processor {
        date_remapper {
            sources = ["level"]
            is_enabled = true
            name = "Last attempt to match date"
        }
    }
    processor {
        status_remapper {
            sources = ["level"]
            is_enabled = true
            name = "Last attempt to match level"
        }
    }
    processor {
        message_remapper {
            sources = ["msg"]
            is_enabled = true
            name = "Last attempt to match msg"
        }
    }
}