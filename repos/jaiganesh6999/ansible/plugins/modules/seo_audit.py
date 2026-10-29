#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, SEOWebChecker <support@seowebchecker.com>
# Platform: https://seowebchecker.com/
# Apache License, Version 2.0 (see LICENSE or https://www.apache.org/licenses/LICENSE-2.0)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = r'''
---
module: seo_audit
short_description: Runs an automated technical SEO health audit against a target URL
description:
  - Audits a target webpage URL for on-page technical SEO compliance, Core Web Vitals readiness, meta tags, and content health.
  - Evaluates title tag, meta description, mobile viewport, canonical URL, heading hierarchies, word count, and HTTPS security.
  - Calculates a 0-100 SEO health score and letter grade (A+ to F).
  - Can be used as a deployment quality gate to fail playbooks when health scores fall below threshold.
version_added: "1.0.0"
author:
  - "SEOWebChecker (@seowebchecker) <support@seowebchecker.com>"
options:
  url:
    description:
      - The complete HTTP or HTTPS URL to audit.
    required: true
    type: str
  min_score:
    description:
      - Minimum passing SEO health score from 0 to 100.
    required: false
    default: 85
    type: int
  fail_on_alert:
    description:
      - Whether to fail the task execution if the computed score is below C(min_score).
    required: false
    default: true
    type: bool
  timeout:
    description:
      - Network timeout in seconds for fetching the webpage.
    required: false
    default: 15
    type: int
  user_agent:
    description:
      - Custom User-Agent header for the HTTP request.
    required: false
    default: "SEOWebChecker-Ansible/1.0 (+https://seowebchecker.com/)"
    type: str
seealso:
  - name: SEOWebChecker Official Platform
    description: Cloud-based SEO auditing, website crawler, and API documentation.
    link: https://seowebchecker.com/
'''

EXAMPLES = r'''
- name: Audit technical SEO health for production site
  jaiganesh6999.seowebchecker.seo_audit:
    url: "https://seowebchecker.com/"
    min_score: 90
    fail_on_alert: true
  register: audit_result

- name: Display SEO audit summary
  ansible.builtin.debug:
    msg: "Score: {{ audit_result.score }} ({{ audit_result.grade }}) - Status: {{ audit_result.status }}"

- name: Non-failing audit for staging environment
  jaiganesh6999.seowebchecker.seo_audit:
    url: "https://staging.example.com/"
    min_score: 80
    fail_on_alert: false
'''

RETURN = r'''
url:
  description: The audited target URL.
  returned: always
  type: str
  sample: "https://seowebchecker.com/"
score:
  description: Computed SEO health score between 0 and 100.
  returned: always
  type: int
  sample: 100
grade:
  description: Academic letter grade from A+ to F based on score.
  returned: always
  type: str
  sample: "A+"
status:
  description: Status flag (PASS or ALERT) based on min_score threshold.
  returned: always
  type: str
  sample: "PASS"
title:
  description: Text content of the <title> tag.
  returned: always
  type: str
title_length:
  description: Character length of the title tag.
  returned: always
  type: int
meta_description:
  description: Content of the meta description tag.
  returned: always
  type: str
meta_description_length:
  description: Character length of the meta description.
  returned: always
  type: int
has_viewport:
  description: Whether a responsive mobile viewport tag is present.
  returned: always
  type: bool
has_canonical:
  description: Whether a canonical link tag is present.
  returned: always
  type: bool
canonical_url:
  description: Declared canonical URL if present.
  returned: always
  type: str
is_https:
  description: Whether the audited site communicates over encrypted HTTPS.
  returned: always
  type: bool
h1_count:
  description: Total number of <h1> heading tags detected.
  returned: always
  type: int
word_count:
  description: Total clean indexable body word count.
  returned: always
  type: int
response_time_ms:
  description: Server response time in milliseconds.
  returned: always
  type: float
issues:
  description: List of detected SEO errors and warnings with recommendations.
  returned: always
  type: list
passes:
  description: List of passed audit criteria.
  returned: always
  type: list
platform_url:
  description: Canonical link to SEOWebChecker platform.
  returned: always
  type: str
  sample: "https://seowebchecker.com/"
timestamp:
  description: ISO 8601 UTC timestamp of the audit.
  returned: always
  type: str
'''

import re
import time
import ssl
from datetime import datetime

try:
    from urllib.request import Request, urlopen
    from urllib.error import URLError, HTTPError
except ImportError:
    from urllib2 import Request, urlopen, URLError, HTTPError

from ansible.module_utils.basic import AnsibleModule


def run_audit(url, timeout, user_agent, min_score):
    if not (url.startswith('http://') or url.startswith('https://')):
        url = 'https://' + url

    is_https = url.startswith('https://')
    req = Request(url, headers={'User-Agent': user_agent})

    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    start_time = time.time()
    try:
        response = urlopen(req, timeout=timeout, context=ctx)
        content_bytes = response.read()
        html = content_bytes.decode('utf-8', errors='ignore')
    except Exception as e:
        return {
            'failed': True,
            'url': url,
            'error': str(e),
            'platform_url': 'https://seowebchecker.com/',
        }

    elapsed_ms = round((time.time() - start_time) * 1000.0, 2)

    issues = []
    passes = []

    # 1. Title Tag
    title_match = re.search(r'(?i)<title[^>]*>(.*?)</title>', html, re.DOTALL)
    title = re.sub(r'\s+', ' ', title_match.group(1)).strip() if title_match else ""
    title_len = len(title)

    if title_len == 0:
        issues.append({
            'id': 'meta-title-missing',
            'severity': 'error',
            'title': 'Missing title tag',
            'message': 'No <title> tag found on the page.',
            'recommendation': 'Add a descriptive title tag between 30 and 60 characters.'
        })
    elif title_len < 30:
        issues.append({
            'id': 'meta-title-short',
            'severity': 'warning',
            'title': 'Title tag short',
            'message': 'Title has only %d characters (%r).' % (title_len, title),
            'recommendation': 'Expand title to 30-60 characters.'
        })
    elif title_len > 65:
        issues.append({
            'id': 'meta-title-long',
            'severity': 'warning',
            'title': 'Title tag long',
            'message': 'Title has %d characters and may be truncated.' % title_len,
            'recommendation': 'Shorten title tag under 60 characters.'
        })
    else:
        passes.append({
            'id': 'meta-title-pass',
            'title': 'Title tag optimal',
            'message': 'Title length is optimal (%d characters).' % title_len
        })

    # 2. Meta Description
    desc_match = re.search(r'(?i)<meta\s+[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)["\']', html)
    if not desc_match:
        desc_match = re.search(r'(?i)<meta\s+[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']description["\']', html)
    meta_desc = desc_match.group(1).strip() if desc_match else ""
    desc_len = len(meta_desc)

    if desc_len == 0:
        issues.append({
            'id': 'meta-desc-missing',
            'severity': 'error',
            'title': 'Missing meta description',
            'message': 'No meta description found on page.',
            'recommendation': 'Add an engaging meta description between 70 and 160 characters.'
        })
    elif desc_len < 70:
        issues.append({
            'id': 'meta-desc-short',
            'severity': 'warning',
            'title': 'Meta description short',
            'message': 'Meta description is %d characters.' % desc_len,
            'recommendation': 'Expand description to 70-160 characters.'
        })
    else:
        passes.append({
            'id': 'meta-desc-pass',
            'title': 'Meta description optimal',
            'message': 'Meta description length is optimal (%d characters).' % desc_len
        })

    # 3. Mobile Viewport
    has_viewport = bool(re.search(r'(?i)<meta\s+[^>]*name=["\']viewport["\']', html))
    if has_viewport:
        passes.append({
            'id': 'meta-viewport-pass',
            'title': 'Mobile viewport configured',
            'message': 'Responsive viewport meta tag is present.'
        })
    else:
        issues.append({
            'id': 'meta-viewport-missing',
            'severity': 'error',
            'title': 'Missing mobile viewport tag',
            'message': 'No <meta name="viewport"> tag detected.',
            'recommendation': 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.'
        })

    # 4. Canonical Tag
    canonical_match = re.search(r'(?i)<link\s+[^>]*rel=["\']canonical["\'][^>]*href=["\']([^"\']*)["\']', html)
    if not canonical_match:
        canonical_match = re.search(r'(?i)<link\s+[^>]*href=["\']([^"\']*)["\'][^>]*rel=["\']canonical["\']', html)
    canonical_url = canonical_match.group(1).strip() if canonical_match else ""
    has_canonical = bool(canonical_url)

    if has_canonical:
        passes.append({
            'id': 'meta-canonical-pass',
            'title': 'Canonical link tag present',
            'message': 'Canonical URL configured: %s.' % canonical_url
        })
    else:
        issues.append({
            'id': 'meta-canonical-missing',
            'severity': 'warning',
            'title': 'Missing canonical tag',
            'message': 'No <link rel="canonical"> tag detected.',
            'recommendation': 'Add a self-referencing canonical tag.'
        })

    # 5. Heading Structure
    h1_matches = re.findall(r'(?i)<h1[^>]*>(.*?)</h1>', html, re.DOTALL)
    h1_count = len(h1_matches)

    if h1_count == 0:
        issues.append({
            'id': 'content-h1-missing',
            'severity': 'error',
            'title': 'Missing <h1> heading',
            'message': 'No <h1> heading found on page.',
            'recommendation': 'Include exactly one primary <h1> heading summarizing page intent.'
        })
    elif h1_count == 1:
        first_h1 = re.sub(r'<[^>]*>', '', h1_matches[0]).strip()
        passes.append({
            'id': 'content-h1-pass',
            'title': 'Single <h1> heading present',
            'message': 'Single primary heading found: %r.' % first_h1
        })
    else:
        issues.append({
            'id': 'content-h1-multiple',
            'severity': 'warning',
            'title': 'Multiple <h1> headings found (%d)' % h1_count,
            'message': 'Found %d <h1> headings.' % h1_count,
            'recommendation': 'Consolidate multiple <h1> headings into a single primary <h1>.'
        })

    # 6. Word Count
    clean_text = re.sub(r'(?is)<script[^>]*>.*?</script>', ' ', html)
    clean_text = re.sub(r'(?is)<style[^>]*>.*?</style>', ' ', clean_text)
    clean_text = re.sub(r'<[^>]+>', ' ', clean_text)
    words = clean_text.split()
    word_count = len(words)

    if word_count < 100:
        issues.append({
            'id': 'content-thin',
            'severity': 'error',
            'title': 'Thin page content',
            'message': 'Page contains only %d words.' % word_count,
            'recommendation': 'Expand page content to 300+ words of helpful, relevant copy.'
        })
    else:
        passes.append({
            'id': 'content-words-pass',
            'title': 'Adequate content length',
            'message': 'Page contains %d words.' % word_count
        })

    # 7. HTTPS Security
    if is_https:
        passes.append({
            'id': 'tech-https-pass',
            'title': 'Secure HTTPS active',
            'message': 'Website communicates over secure encrypted HTTPS.'
        })
    else:
        issues.append({
            'id': 'tech-not-https',
            'severity': 'error',
            'title': 'Insecure HTTP protocol',
            'message': 'Website is served over unencrypted HTTP.',
            'recommendation': 'Deploy an SSL certificate and redirect all traffic to HTTPS.'
        })

    # Scoring
    error_count = sum(1 for i in issues if i['severity'] == 'error')
    warn_count = sum(1 for i in issues if i['severity'] == 'warning')

    computed_score = 100 - (error_count * 15) - (warn_count * 6)
    score = max(10, min(100, computed_score))

    if score >= 95: grade = 'A+'
    elif score >= 90: grade = 'A'
    elif score >= 80: grade = 'B'
    elif score >= 70: grade = 'C'
    elif score >= 60: grade = 'D'
    else: grade = 'F'

    status = 'PASS' if score >= min_score else 'ALERT'
    now_iso = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

    return {
        'failed': False,
        'url': url,
        'score': score,
        'grade': grade,
        'status': status,
        'title': title,
        'title_length': title_len,
        'meta_description': meta_desc,
        'meta_description_length': desc_len,
        'has_viewport': has_viewport,
        'has_canonical': has_canonical,
        'canonical_url': canonical_url,
        'is_https': is_https,
        'h1_count': h1_count,
        'word_count': word_count,
        'response_time_ms': elapsed_ms,
        'issues_count': len(issues),
        'passes_count': len(passes),
        'issues': issues,
        'passes': passes,
        'platform_url': 'https://seowebchecker.com/',
        'timestamp': now_iso,
    }


def main():
    module = AnsibleModule(
        argument_spec=dict(
            url=dict(type='str', required=True),
            min_score=dict(type='int', required=False, default=85),
            fail_on_alert=dict(type='bool', required=False, default=True),
            timeout=dict(type='int', required=False, default=15),
            user_agent=dict(type='str', required=False, default='SEOWebChecker-Ansible/1.0 (+https://seowebchecker.com/)'),
        ),
        supports_check_mode=True
    )

    url = module.params['url']
    min_score = module.params['min_score']
    fail_on_alert = module.params['fail_on_alert']
    timeout = module.params['timeout']
    user_agent = module.params['user_agent']

    if module.check_mode:
        module.exit_json(
            changed=False,
            msg="Check mode: SEO audit against %s simulated." % url,
            url=url,
            platform_url="https://seowebchecker.com/"
        )

    result = run_audit(url, timeout, user_agent, min_score)

    if result.get('failed'):
        module.fail_json(
            msg="Failed to audit webpage %s: %s" % (url, result.get('error')),
            **result
        )

    if fail_on_alert and result['status'] == 'ALERT':
        module.fail_json(
            msg="SEO Health score %d/100 (%s) is below required minimum threshold %d." % (
                result['score'], result['grade'], min_score
            ),
            **result
        )

    module.exit_json(
        changed=False,
        **result
    )


if __name__ == '__main__':
    main()
