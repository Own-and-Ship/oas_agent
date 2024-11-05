# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  module Agent
    module Configuration
      class DefaultSource
        def to_h
          {
            log_level: :info,
            report_ruby_deprecations: true,
            suppress_ruby_warnings: true,
            api: {
              host: "ownandship.io",
              port: 443,
              enforce_tls: true,
              read_timeout: 10,
              write_timeout: 10,
              open_timeout: 1,
              keepalive_timeout: 60,
              version: "1",
              reports_encoding: "identity",
              reports_content_type: "application/json",
              reports_request_path: "/api/report/deprecation",
              min_data_size_for_compress_bytes: 64 * 1024, # 64kB,
              max_data_size_for_post_bytes: 10 * 1024 * 1024, # 10 MB, no particular reason other than seems reasonable without being so large that it's too much overhead
              max_retries_per_record: 3
            },
            reporter: {
              max_reports_to_queue: 5000,
              max_reports_to_batch: 100,
              batched_report_timeout: 10,
              send_immediately: false
            }
          }
        end
      end
    end
  end
end
