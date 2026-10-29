# frozen_string_literal: true

require_relative "seowebchecker_seoaudit/version"
require_relative "seowebchecker_seoaudit/auditor"

module SeoWebChecker
  module SeoAudit
    def self.audit(url, options = {})
      Auditor.new(**options).audit(url)
    end
  end
end
