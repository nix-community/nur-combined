Package.describe({
  name: 'seowebchecker:seoaudit-sdk',
  version: '1.0.0',
  summary: 'Automated on-page technical SEO audits, meta tag validation, and Core Web Vitals checks by SEOWebChecker.',
  git: 'https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk.git',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom(['2.8', '2.14', '3.0']);
  api.use('ecmascript');
  api.mainModule('index.js', ['server', 'client']);
  api.export('SEOAuditor');
});

Package.onTest(function(api) {
  api.use(['ecmascript', 'tinytest']);
  api.use('seowebchecker:seoaudit-sdk');
  api.mainModule('tests.js');
});
