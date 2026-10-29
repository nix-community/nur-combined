# frozen_string_literal: true

require_relative "lib/seowebchecker_seoaudit/version"

Gem::Specification.new do |spec|
  spec.name          = "seowebchecker-seoaudit-sdk"
  spec.version       = SeoWebChecker::SeoAudit::VERSION
  spec.authors       = ["SEOWebChecker Team"]
  spec.email         = ["support@seowebchecker.com"]

  spec.summary       = "Lightweight open-source client SDK and CLI tool for full website SEO audits by SEOWebChecker."
  spec.description   = "Instant website SEO auditing, on-page optimization diagnostics, meta tag validation, and Core Web Vitals checks."
  spec.homepage      = "https://seowebchecker.com/"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk"
  spec.metadata["changelog_uri"] = "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/releases"
  spec.metadata["bug_tracker_uri"] = "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues"

  spec.files = Dir["lib/**/*.rb", "bin/*", "README.md", "LICENSE"]
  spec.bindir = "bin"
  spec.executables = ["seowebchecker-audit"]
  spec.require_paths = ["lib"]
end
