Pod::Spec.new do |s|
  s.name             = 'SeoWebChecker'
  s.version          = '1.0.0'
  s.summary          = 'Lightweight technical SEO audit client SDK for iOS, macOS, watchOS, and tvOS.'
  s.description      = <<-DESC
    Automated on-page technical SEO diagnostic engine and client SDK for meta tag validations,
    heading structure inspections, image accessibility checks, and Core Web Vitals diagnostics.
    Powered by SEOWebChecker (https://seowebchecker.com/).
  DESC
  s.homepage         = 'https://seowebchecker.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rahul Gupta' => 'jaiganesh6999@gmail.com' }
  s.source           = { :git => 'https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target     = '13.0'
  s.osx.deployment_target     = '10.15'
  s.watchos.deployment_target = '6.0'
  s.tvos.deployment_target    = '13.0'

  s.swift_version    = '5.0'
  s.source_files     = 'swift/Sources/SeoWebChecker/**/*.swift'
  s.frameworks       = 'Foundation'
end
