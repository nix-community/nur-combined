use strict;
use warnings;
use Test::More tests => 4;

use_ok('SeoWebChecker::SeoAudit');

my $auditor = SeoWebChecker::SeoAudit->new();
isa_ok($auditor, 'SeoWebChecker::SeoAudit');

my $html = '<html><head><title>Test Page</title><meta name="viewport" content="width=device-width"></head><body><h1>Welcome</h1></body></html>';
my $result = $auditor->audit_html($html, 'https://example.com');

ok($result->{score}{overall} >= 70, 'Overall score computed');
is($result->{url}, 'https://example.com', 'URL preserved');
