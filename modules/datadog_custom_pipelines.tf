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

resource "datadog_logs_custom_pipeline" "Traefik_with_unquoted_access_log_fixes_dont_use_builtin_integration" {
    filter {
        query = "source:traefik"
    }
    name = "Traefik with unquoted access log fixes (don't use builtin integration)"
    is_enabled = true
    processor {
        grok_parser {
            name = "Grok parser"
            is_enabled = true
            source = "message"
            samples = [
                "10.32.0.1 - - [07/Dec/2018:06:07:03 +0000] \"GET / HTTP/1.1\" 302 5 \"-\" \"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36\" 132170 \"entrypoint redirect for http\" \"/\" 0ms",
                "time=\"2019-04-05T11:57:47Z\" level=info msg=\"Skipping same configuration for provider consul_catalog\"",
                "10.0.5.190 - - [13/Mar/2020:19:20:28 +0000] \"GET /ping HTTP/1.1\" 200 2 \"-\" \"-\" 228413 \"ping@internal\" - 0ms",
                "10.0.11.71 - - [13/Mar/2020:19:41:31 +0000] \"GET / HTTP/1.1\" - - \"-\" \"-\" 392171 - - 0ms"
            ]
            grok {
                support_rules = "_duration %%{number:duration:scale(1000000)}\n_traefik_backend_url %%{notSpace:traefik.backend_url}\n_traefik_name %%{regex(\"[^\\\\\\\"]*\"):traefik.name}\n_total_request %%{number:traefik.request_total}\n_auth %%{notSpace:http.auth:nullIf(\"-\")}\n_bytes_written %%{integer:network.bytes_written}\n_client_ip %%{ipOrHost:network.client.ip}\n_version HTTP\\/%%{regex(\"\\\\d+\\\\.\\\\d+\"):http.version}\n_url %%{notSpace:http.url}\n_ident %%{notSpace:http.ident:nullIf(\"-\")}\n_user_agent %%{regex(\"[^\\\\\\\"]*\"):http.useragent}\n_referer %%{notSpace:http.referer}\n_status_code %%{integer:http.status_code}\n_method %%{word:http.method}\n_date_access %%{date(\"dd/MMM/yyyy:HH:mm:ss Z\"):date_access}\n"
                match_rules = "access.common %%{_client_ip} %%{_ident} %%{_auth} \\[%%{_date_access}\\] \"(?>%%{_method} |)%%{_url}(?> %%{_version}|)\" %%{_status_code} (?>%%{_bytes_written}|-) \"%%{_referer}\" \"%%{_user_agent}\" %%{_total_request} \"%%{_traefik_name}\" \"?%%{_traefik_backend_url}(\"|“)? %%{_duration}ms.*\n\naccess.common2 %%{_client_ip} %%{_ident} %%{_auth} \\[%%{_date_access}\\] \"(?>%%{_method} |)%%{_url}(?> %%{_version}|)\" (%%{_status_code}|-) (?>%%{_bytes_written}|-) \"%%{_referer}\" \"%%{_user_agent}\" %%{_total_request} \"?%%{_traefik_name}\"? \"?%%{_traefik_backend_url}(\"|“)? %%{_duration}ms.*\n\ndata_keyvalue %%{data::keyvalue}"
            }
        }
    }
    processor {
        message_remapper {
            name = "Message"
            is_enabled = true
            sources = ["msg"]
        }
    }
    processor {
        attribute_remapper {
            name = "Remap RequestMethod"
            is_enabled = true
            sources = ["RequestMethod"]
            source_type = "attribute"
            target = "http.method"
            target_type = "attribute"
            preserve_source = false
            override_on_conflict = false
        }
    }
    processor {
        attribute_remapper {
            name = "Remap Duration"
            is_enabled = true
            sources = ["Duration"]
            source_type = "attribute"
            target = "duration"
            target_type = "attribute"
            preserve_source = false
            override_on_conflict = false
        }
    }
    processor {
        attribute_remapper {
            name = "Remap ClientHost"
            is_enabled = true
            sources = ["ClientHost"]
            source_type = "attribute"
            target = "network.client.ip"
            target_type = "attribute"
            preserve_source = false
            override_on_conflict = false
        }
    }
    processor {
        attribute_remapper {
            name = "Remap ClientPort"
            is_enabled = true
            sources = ["ClientPort"]
            source_type = "attribute"
            target = "network.client.port"
            target_type = "attribute"
            preserve_source = false
            override_on_conflict = false
        }
    }
    processor {
        attribute_remapper {
            name = "Remap statusCode"
            is_enabled = true
            sources = ["OriginStatus", "DownstreamStatus"]
            source_type = "attribute"
            target = "http.status_code"
            target_type = "attribute"
            preserve_source = false
            override_on_conflict = false
        }
    }
    processor {
        attribute_remapper {
            name = "Remap RequestContentSize"
            is_enabled = true
            sources = ["RequestContentSize"]
            source_type = "attribute"
            target = "network.bytes_read"
            target_type = "attribute"
            preserve_source = false
            override_on_conflict = false
        }
    }
    processor {
        attribute_remapper {
            name = "Remap DownstreamContentSize"
            is_enabled = true
            sources = ["DownstreamContentSize"]
            source_type = "attribute"
            target = "network.bytes_written"
            target_type = "attribute"
            preserve_source = false
            override_on_conflict = false
        }
    }
    processor {
        url_parser {
            name = "name"
            is_enabled = true
            sources = ["http.url", "RequestPath"]
            target = "http.url_details"
            normalize_ending_slashes = false
        }
    }
    processor {
        user_agent_parser {
            name = "name"
            is_enabled = true
            sources = ["http.useragent"]
            target = "http.useragent_details"
            is_encoded = false
        }
    }
    processor {
        date_remapper {
            name = "Define official timestamp of log"
            is_enabled = true
            sources = ["date_access"]
        }
    }
    processor {
        category_processor {
            name = "Categorise status code"
            is_enabled = true
            category {
                name = "OK"
                filter {
                    query = "@http.status_code:[200 TO 299]"
                }
            }
            category {
                name = "notice"
                filter {
                    query = "@http.status_code:[300 TO 399]"
                }
            }
            category {
                name = "warning"
                filter {
                    query = "@http.status_code:[400 TO 499]"
                }
            }
            category {
                name = "error"
                filter {
                    query = "@http.status_code:[500 TO 599]"
                }
            }
            target = "http.status_category"
        }
    }
    processor {
        status_remapper {
            name = "Status to level"
            is_enabled = true
            sources = ["http.status_category", "level"]
        }
    }
}