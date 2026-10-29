# SeoWebChecker::SeoAudit (Perl / CPAN)

[![MetaCPAN](https://badge.fury.io/pl/SeoWebChecker-SeoAudit.svg)](https://metacpan.org/pod/SeoWebChecker::SeoAudit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

Lightweight open-source Perl client SDK and CLI tool for full website SEO audits and on-page optimization.

Official website: **[https://seowebchecker.com/](https://seowebchecker.com/)**

## Installation

Install from CPAN:

```bash
cpanm SeoWebChecker::SeoAudit
```

## Quick Start (Perl)

```perl
use SeoWebChecker::SeoAudit;

my $auditor = SeoWebChecker::SeoAudit->new();
my $result  = $auditor->audit_html($html, 'https://example.com');

print "Score: " . $result->{score}{overall} . "/100\n";
```

## License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
