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

resource "datadog_logs_custom_pipeline" "cadence-matching_and_cadence-history" {
    filter {
        query = "service:(cadence-matching OR cadence-server)"
    }
    name = "cadence-matching and cadence-history"
    is_enabled = true
    processor {
        pipeline {
            is_enabled = true
            filter {
                query = "@msg:none"
            }
            name = "msg set to \"none\""
            processor {
                message_remapper {
                    name = "Define lifecycle as official Message field"
                    is_enabled = true
                    sources = ["lifecycle"]
                }
            }
        }
    }
    processor {
        message_remapper {
            is_enabled = true
            sources = ["msg"]
            name = "Define msg as official Message field"
        }
    }
    processor {
        date_remapper {
            is_enabled = true
            sources = ["ts"]
            name = "Define ts as the date attribute"
        }
    }
    processor {
        status_remapper {
            is_enabled = true
            sources = ["level"]
            name = "Define level as status attribute"
        }
    }
}