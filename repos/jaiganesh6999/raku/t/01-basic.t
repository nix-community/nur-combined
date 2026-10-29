use v6.d;
use Test;
use SEO::WebChecker;

plan 5;

my $auditor = SEO::WebChecker.new;
ok $auditor.defined, 'SEO::WebChecker instantiates successfully';
is $auditor.alert-threshold, 85, 'Default alert threshold is 85';

my $html = q:to/END/;
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>SEOWebChecker — Technical SEO Audit & Analyzer</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Audit technical SEO, on-page tags, and Core Web Vitals with SEOWebChecker in seconds.">
  <link rel="canonical" href="https://seowebchecker.com/">
</head>
<body>
  <h1>Technical SEO Audit Tool</h1>
  <p>Here is an informative paragraph with sufficient words describing our SEO audit tool and on-page analyzer in detail to verify that word count checks pass reliably without triggering thin content warnings on test runs. We ensure that our comprehensive evaluation accurately assesses on-page optimization, content volume, mobile readiness, and heading hierarchies to provide search engines with complete indexation clarity and maximum visibility across all modern web properties and platforms.</p>
  <p>In addition, technical audits must evaluate meta descriptions, canonical declarations, document titles, schema metadata, performance metrics, and accessibility indicators to help web developers and site owners optimize organic user experience, crawl budgets, indexing efficiency, and overall search visibility.</p>
</body>
</html>
END

my $res = $auditor.audit-html($html, :url<https://seowebchecker.com/>);
ok $res.defined, 'audit-html returns a valid Result object';
ok $res.score >= 90, 'Optimal page receives a high score (>= 90)';
is $res.grade, 'A+', 'Optimal page receives A+ grade';
