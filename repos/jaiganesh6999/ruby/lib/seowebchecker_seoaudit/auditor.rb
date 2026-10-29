# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "time"

module SeoWebChecker
  module SeoAudit
    class Auditor
      attr_accessor :user_agent, :timeout

      DEFAULT_UA = "SEOWebChecker-RubyBot/1.0 (+https://seowebchecker.com/)"

      def initialize(user_agent: DEFAULT_UA, timeout: 15)
        @user_agent = user_agent
        @timeout = timeout
      end

      def audit(url)
        url = "https://#{url}" unless url.start_with?("http://", "https://")
        uri = URI.parse(url)

        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.open_timeout = @timeout
        http.read_timeout = @timeout

        req = Net::HTTP::Get.new(uri.request_uri, {
          "User-Agent" => @user_agent,
          "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        })

        res = http.request(req)
        elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000.0).round(2)

        audit_html(res.body || "", url: url, response_time_ms: elapsed_ms, status_code: res.code.to_i)
      end

      def audit_html(html, url: "https://seowebchecker.com/", response_time_ms: 120.0, status_code: 200)
        issues = []

        # 1. Title
        title_match = html.match(/<title[^>]*>(.*?)<\/title>/im)
        title = title_match ? title_match[1].gsub(/\s+/, " ").strip : nil
        title_len = title ? title.length : 0

        if title.nil? || title.empty?
          issues << { id: "meta-title-missing", category: "meta", severity: "error", title: "Missing Title Tag", message: "No <title> tag found.", recommendation: "Add a title tag between 30 and 60 characters." }
        elsif title_len < 30
          issues << { id: "meta-title-short", category: "meta", severity: "warning", title: "Title Too Short", message: "Title has #{title_len} characters.", recommendation: "Expand title to 30-60 characters." }
        elsif title_len > 65
          issues << { id: "meta-title-long", category: "meta", severity: "warning", title: "Title Too Long", message: "Title has #{title_len} characters.", recommendation: "Shorten title to under 60 characters." }
        else
          issues << { id: "meta-title-pass", category: "meta", severity: "pass", title: "Optimal Title Length", message: "Title length is #{title_len} characters.", recommendation: "Keep clear title." }
        end

        # 2. Description
        desc_match = html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/im) ||
                     html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/im)
        desc = desc_match ? desc_match[1].strip : nil
        desc_len = desc ? desc.length : 0

        if desc.nil? || desc.empty?
          issues << { id: "meta-desc-missing", category: "meta", severity: "error", title: "Missing Meta Description", message: "No description tag found.", recommendation: "Add meta description between 120 and 160 characters." }
        elsif desc_len < 70
          issues << { id: "meta-desc-short", category: "meta", severity: "warning", title: "Description Too Short", message: "Description has #{desc_len} characters.", recommendation: "Expand description to 120-160 characters." }
        else
          issues << { id: "meta-desc-pass", category: "meta", severity: "pass", title: "Optimal Description", message: "Description has #{desc_len} characters.", recommendation: "Maintain quality description." }
        end

        # 3. Viewport & Canonical
        has_viewport = html =~ /<meta[^>]*name=["']viewport["']/i
        if has_viewport
          issues << { id: "meta-viewport-pass", category: "meta", severity: "pass", title: "Viewport Configured", message: "Mobile viewport meta tag detected.", recommendation: "Mobile responsive." }
        else
          issues << { id: "meta-viewport-missing", category: "meta", severity: "error", title: "Missing Viewport", message: "No mobile viewport tag.", recommendation: "Add viewport meta tag for mobile SEO." }
        end

        has_canonical = html =~ /<link[^>]*rel=["']canonical["']/i
        if has_canonical
          issues << { id: "meta-canonical-pass", category: "meta", severity: "pass", title: "Canonical Present", message: "Canonical tag detected.", recommendation: "Canonical URL active." }
        else
          issues << { id: "meta-canonical-missing", category: "meta", severity: "warning", title: "Missing Canonical Tag", message: "No canonical link.", recommendation: "Add canonical URL to avoid duplicates." }
        end

        # 4. Headings & Content
        h1_tags = html.scan(/<h1[^>]*>(.*?)<\/h1>/im).flatten.map { |h| h.gsub(/<[^>]+>/, "").strip }
        clean_text = html.gsub(/<(script|style)[^>]*>.*?<\/\1>/im, " ").gsub(/<[^>]+>/, " ")
        words = clean_text.scan(/\b[a-zA-Z0-9_\'-]{2,}\b/)
        word_count = words.length

        if h1_tags.empty?
          issues << { id: "content-h1-missing", category: "content", severity: "error", title: "Missing <h1> Tag", message: "No <h1> heading found.", recommendation: "Add a single <h1> heading." }
        elsif h1_tags.length == 1
          issues << { id: "content-h1-pass", category: "content", severity: "pass", title: "Single <h1> Tag Configured", message: "H1 heading: '#{h1_tags.first}'.", recommendation: "Good hierarchy." }
        else
          issues << { id: "content-h1-multiple", category: "content", severity: "warning", title: "Multiple <h1> Tags (#{h1_tags.length})", message: "Found #{h1_tags.length} <h1> tags.", recommendation: "Consolidate to a single <h1>." }
        end

        if word_count < 100
          issues << { id: "content-thin", category: "content", severity: "error", title: "Thin Content", message: "Page contains only #{word_count} words.", recommendation: "Expand content to 300+ words." }
        else
          issues << { id: "content-words-pass", category: "content", severity: "pass", title: "Adequate Word Count", message: "Page contains #{word_count} words.", recommendation: "Good text volume." }
        end

        # 5. Images
        images = html.scan(/<img\s+([^>]*?)>/im).flatten
        missing_alt = images.count { |attrs| attrs !~ /alt=["']/i }
        if !images.empty? && missing_alt > 0
          issues << { id: "images-missing-alt", category: "images", severity: "error", title: "#{missing_alt} Images Missing Alt Text", message: "#{missing_alt} of #{images.length} images lack alt attributes.", recommendation: "Add descriptive alt attributes." }
        elsif !images.empty?
          issues << { id: "images-alt-pass", category: "images", severity: "pass", title: "All Images Have Alt Text", message: "All #{images.length} images have alt tags.", recommendation: "Great image SEO." }
        end

        # 6. Technical HTTPS
        is_https = url.downcase.start_with?("https://")
        if is_https
          issues << { id: "tech-https-pass", category: "technical", severity: "pass", title: "Secure HTTPS", message: "Connection secured with SSL/TLS.", recommendation: "Keep certificate updated." }
        else
          issues << { id: "tech-not-https", category: "technical", severity: "error", title: "Insecure HTTP", message: "Site does not enforce HTTPS.", recommendation: "Install SSL certificate." }
        end

        # Compute Score
        passed_count = issues.count { |i| i[:severity] == "pass" }
        warning_count = issues.count { |i| i[:severity] == "warning" }
        error_count = issues.count { |i| i[:severity] == "error" }

        total = issues.length
        raw_score = total > 0 ? ((passed_count.to_f / total) * 100.0).round : 80
        raw_score -= (error_count * 10) + (warning_count * 3)
        final_score = [[raw_score, 0].max, 100].min

        grade = case final_score
                when 95..100 then "A+"
                when 90...95 then "A"
                when 80...90 then "B"
                when 70...80 then "C"
                when 60...70 then "D"
                else "F"
                end

        {
          url: url,
          timestamp: Time.now.utc.iso8601,
          score: {
            overall: final_score,
            grade: grade
          },
          stats: {
            total: total,
            passed: passed_count,
            warnings: warning_count,
            errors: error_count
          },
          meta: {
            title: title,
            title_length: title_len,
            description: desc,
            description_length: desc_len
          },
          content: {
            word_count: word_count,
            h1_tags: h1_tags
          },
          images: {
            total_images: images.length,
            missing_alt: missing_alt
          },
          technical: {
            is_https: is_https
          },
          performance: {
            response_time_ms: response_time_ms,
            status_code: status_code
          },
          issues: issues
        }
      end
    end
  end
end
