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
resource "datadog_logs_custom_pipeline" "cloud_consul-ama,operation,provider,blob,data-plane-config,network,region,consul-service,host-manager-service,image" {
    filter {
        query = "service:(cloud-consul-ama OR cloud-operation OR cloud-provider OR cloud-blob OR cloud-data-plane-config OR cloud-network OR cloud-region OR cloud-consul-service OR cloud-image-service OR cloud-host-manager-service)"
    }
    name = "cloud: consul-ama, operation, provider, blob, data-plane-config, network, region, consul-service, host-manager-service, image"
    is_enabled = true
    processor {
        message_remapper {
            name = "Assign msg, message to official Message field"
            is_enabled = true
            sources = ["msg", "@message"]
        }
    }
    processor {
        grok_parser {
            name = "Date, level, msg processor"
            is_enabled = true
            source = "message"
            # samples = ["172.17.0.1 - - [19/Dec/2019:15:23:37 +0000] "POST /consul/2019-11-20/.internal/clusters/11ea2272-5dd8-7571-93ec-0242ac110003/host-alive HTTP/1.1" 200 26 "" "Go-http-client/1.1"", "2019-12-18T20:59:28.451Z [WARN]  consul-ama.grpc: WARNING: 2019/12/18 20:59:28 grpc: Server.Serve failed to create ServerTransport:  connection error: desc = "transport: http2Server.HandleStreams failed to receive the preface from client: EOF"", "172.17.0.1 - - [11/Feb/2020:09:40:07 +0000] "GET /consulama/2019-09-10/subscriptions/02dd1374-6542-4060-8dd7-75d686331850/resourceGroups/hourlytest-prod-1233/providers/Microsoft.CustomProviders/resourceProviders/public/consulClusters/test HTTP/1.1" 202 434 "" """, "WARNING: 2020/03/23 16:46:10 grpc: Server.Serve failed to create ServerTransport:  connection error: desc = "transport: http2Server.HandleStreams failed to receive the preface from client: read tcp 172.17.0.9:28080->10.0.64.61:56492: read: connection reset by peer""]
            # grok = "{'support_rules': '', 'match_rules': 'rule_syslog %{date("yyyy-MM-dd\'T\'HH:mm:ss.SSSZ"):date} \\[%{word:level}\\] +%{notSpace:component}: %{data:msg}\nrule_syslog2 %{word:level}: %{date("yyyy/MM/dd HH:mm:ss"):date} +%{notSpace:component}: %{data:msg}\nrule_apache_common %{ipv4:network.client.ip}\\s+-\\s+-\\s+\\[%{date("dd/MMM/yyyy:HH:mm:ss Z"):date}\\]\\s+\\"%{word:http.method}\\s+%{notSpace:http.url}\\s+%{notSpace:http.version}\\"\\s+%{integer:http.status_code}\\s+%{integer:bytes}\\s+\\"\\"\\s+\\"%{notSpace:http.user_agent}?\\"'}"
            samples = [
                "172.17.0.1 - - [19/Dec/2019:15:23:37 +0000] \"POST /consul/2019-11-20/.internal/clusters/11ea2272-5dd8-7571-93ec-0242ac110003/host-alive HTTP/1.1\" 200 26 \"\" \"Go-http-client/1.1\"",
                "2019-12-18T20:59:28.451Z [WARN]  consul-ama.grpc: WARNING: 2019/12/18 20:59:28 grpc: Server.Serve failed to create ServerTransport:  connection error: desc = \"transport: http2Server.HandleStreams failed to receive the preface from client: EOF\"",
                "172.17.0.1 - - [11/Feb/2020:09:40:07 +0000] \"GET /consulama/2019-09-10/subscriptions/02dd1374-6542-4060-8dd7-75d686331850/resourceGroups/hourlytest-prod-1233/providers/Microsoft.CustomProviders/resourceProviders/public/consulClusters/test HTTP/1.1\" 202 434 \"\" \"\"",
                "WARNING: 2020/03/23 16:46:10 grpc: Server.Serve failed to create ServerTransport:  connection error: desc = \"transport: http2Server.HandleStreams failed to receive the preface from client: read tcp 172.17.0.9:28080->10.0.64.61:56492: read: connection reset by peer\""
            ]
            grok {
                support_rules = ""
                match_rules = "rule_syslog %%{date(\"yyyy-MM-dd'T'HH:mm:ss.SSSZ\"):date} \\[%%{word:level}\\] +%%{notSpace:component}: %%{data:msg}\nrule_syslog2 %%{word:level}: %%{date(\"yyyy/MM/dd HH:mm:ss\"):date} +%%{notSpace:component}: %%{data:msg}\nrule_apache_common %%{ipv4:network.client.ip}\\s+-\\s+-\\s+\\[%%{date(\"dd/MMM/yyyy:HH:mm:ss Z\"):date}\\]\\s+\\\"%%{word:http.method}\\s+%%{notSpace:http.url}\\s+%%{notSpace:http.version}\\\"\\s+%%{integer:http.status_code}\\s+%%{integer:bytes}\\s+\\\"\\\"\\s+\\\"%%{notSpace:http.user_agent}?\\\""
            }
        }
    }
    processor {
        date_remapper {
            name = "Assign date to official Date field"
            is_enabled = true
            sources = ["date", "@timestamp"]
        }
    }
    processor {
        status_remapper {
            name = "Assign level to official Status field"
            is_enabled = true
            sources = ["level", "@level"]
        }
    }
}