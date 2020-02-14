resource "datadog_logs_custom_pipeline" "Vault" {
    filter {
        query = "service:vault"
    }
    name = "Vault"
    is_enabled = true
    processor {
        grok_parser {
            samples = [
          "2019-12-19T13:57:27.915Z [ERROR] core: failed to acquire lock: error=\"failed to create session: Unexpected response code: 500 (No known Consul servers)\""]
            source = "message"
            grok {
                support_rules = ""
                match_rules = "rule %{date(\"yyyy-MM-dd'T'HH:mm:ss.SSSZ\"):date} \\[%{word:level}\\] +%{notSpace:component}: %{data:msg}"
            }

        }
    }
}