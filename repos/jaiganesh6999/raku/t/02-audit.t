use v6.d;
use Test;
use SEO::WebChecker;

plan 4;

my $auditor = SEO::WebChecker.new(:alert-threshold(80));

# HTML with missing title, missing viewport, missing H1, insecure HTTP
my $broken-html = q:to/END/;
<html>
<body>
  <div>Just some raw text without meta tags, title, or viewport.</div>
</body>
</html>
END

my $res = $auditor.audit-html($broken-html, :url<http://insecure-example.com/>);
ok $res.defined, 'Audit completed on broken HTML';
ok $res.score < 80, 'Score reflects issues (< 80)';
is $res.status, 'ALERT', 'Status flagged as ALERT when below threshold';
ok $res.issues.elems >= 3, 'Multiple issues detected (missing title, viewport, H1, https)';
