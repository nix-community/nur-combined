# @summary Installs the standalone SEOWebChecker auditing script and dependencies.
#
# @api private
#
class seowebchecker::install {
  assert_private()

  $script_content = @(EOF)
#!/usr/bin/env bash
# SEOWebChecker — Automated Technical SEO Auditor for Puppet
# Platform: https://seowebchecker.com/
set -euo pipefail

URL="${1:-https://seowebchecker.com/}"
THRESHOLD="${2:-85}"
OUT_FILE="${3:-}"
FORMAT="${4:-json}"

USER_AGENT="SEOWebChecker-Puppet/1.0 (+https://seowebchecker.com/)"

TMP_HTML=$(mktemp)
TMP_HEADERS=$(mktemp)
trap 'rm -f "$TMP_HTML" "$TMP_HEADERS"' EXIT

START_TIME=$(date +%s%3N)
STATUS_CODE=$(curl -s -L -A "$USER_AGENT" -D "$TMP_HEADERS" -o "$TMP_HTML" -w "%{http_code}" --max-time 15 "$URL" || echo "000")
END_TIME=$(date +%s%3N)
ELAPSED_MS=$((END_TIME - START_TIME))

TITLE=$(grep -iPo '(?<=<title>)(.*?)(?=</title>)' "$TMP_HTML" | head -n 1 | tr -d '\r\n' | sed 's/^[ \t]*//;s/[ \t]*$//' || echo "")
TITLE_LEN=${#TITLE}

META_DESC=$(grep -iPo '(?<=<meta name="description" content=")(.*?)(?=")' "$TMP_HTML" | head -n 1 | tr -d '\r\n' || echo "")
if [ -z "$META_DESC" ]; then
  META_DESC=$(grep -iPo '(?<=<meta content=")(.*?)(?=" name="description")' "$TMP_HTML" | head -n 1 | tr -d '\r\n' || echo "")
fi
DESC_LEN=${#META_DESC}

VIEWPORT=false
if grep -qi '<meta[^>]*name=["'\'']viewport["'\'']' "$TMP_HTML"; then
  VIEWPORT=true
fi

CANONICAL=""
CANONICAL_URL=$(grep -iPo '(?<=<link rel="canonical" href=")(.*?)(?=")' "$TMP_HTML" | head -n 1 | tr -d '\r\n' || echo "")
if [ -n "$CANONICAL_URL" ]; then
  CANONICAL=true
else
  CANONICAL=false
fi

H1_COUNT=$(grep -io '<h1[^>]*>' "$TMP_HTML" | wc -l | tr -d ' ')
H1_FIRST=$(grep -iPo '(?<=<h1[^>]*>)(.*?)(?=</h1>)' "$TMP_HTML" | head -n 1 | sed -e 's/<[^>]*>//g' | tr -d '\r\n' || echo "")

WORDS=$(sed -e 's/<script[^>]*>.*?<\/script>//gI' -e 's/<style[^>]*>.*?<\/style>//gI' -e 's/<[^>]*>/ /g' "$TMP_HTML" | wc -w | tr -d ' ')

IS_HTTPS=false
if [[ "$URL" == https://* ]]; then
  IS_HTTPS=true
fi

ERRORS=0
WARNINGS=0
ISSUES=()
PASSES=()

# Title tag check
if [ -z "$TITLE" ]; then
  ERRORS=$((ERRORS + 1))
  ISSUES+=('{"id":"meta-title-missing","severity":"error","title":"Missing title tag","message":"No <title> tag found on the page.","recommendation":"Add a title between 30 and 60 characters."}')
elif [ "$TITLE_LEN" -lt 30 ]; then
  WARNINGS=$((WARNINGS + 1))
  ISSUES+=('{"id":"meta-title-short","severity":"warning","title":"Title tag short","message":"Title has only '"$TITLE_LEN"' characters.","recommendation":"Expand title to 30-60 characters."}')
elif [ "$TITLE_LEN" -gt 65 ]; then
  WARNINGS=$((WARNINGS + 1))
  ISSUES+=('{"id":"meta-title-long","severity":"warning","title":"Title tag long","message":"Title has '"$TITLE_LEN"' characters.","recommendation":"Shorten title tag under 60 characters."}')
else
  PASSES+=('{"id":"meta-title-pass","title":"Title tag optimal","message":"Title length is optimal ('"$TITLE_LEN"' chars)."}')
fi

# Meta description check
if [ -z "$META_DESC" ]; then
  ERRORS=$((ERRORS + 1))
  ISSUES+=('{"id":"meta-desc-missing","severity":"error","title":"Missing meta description","message":"No meta description found.","recommendation":"Add a description between 70 and 160 characters."}')
elif [ "$DESC_LEN" -lt 70 ]; then
  WARNINGS=$((WARNINGS + 1))
  ISSUES+=('{"id":"meta-desc-short","severity":"warning","title":"Meta description short","message":"Description is '"$DESC_LEN"' characters.","recommendation":"Expand description to 70-160 characters."}')
else
  PASSES+=('{"id":"meta-desc-pass","title":"Meta description optimal","message":"Meta description length is optimal ('"$DESC_LEN"' chars)."}')
fi

# Viewport check
if [ "$VIEWPORT" = "true" ]; then
  PASSES+=('{"id":"meta-viewport-pass","title":"Mobile viewport configured","message":"Responsive viewport tag present."}')
else
  ERRORS=$((ERRORS + 1))
  ISSUES+=('{"id":"meta-viewport-missing","severity":"error","title":"Missing viewport tag","message":"No responsive viewport meta tag detected.","recommendation":"Add viewport tag with width=device-width."}')
fi

# Canonical check
if [ "$CANONICAL" = "true" ]; then
  PASSES+=('{"id":"meta-canonical-pass","title":"Canonical tag present","message":"Canonical URL configured correctly."}')
else
  WARNINGS=$((WARNINGS + 1))
  ISSUES+=('{"id":"meta-canonical-missing","severity":"warning","title":"Missing canonical tag","message":"No canonical link declared.","recommendation":"Add a self-referencing canonical URL."}')
fi

# Heading check
if [ "$H1_COUNT" -eq 0 ]; then
  ERRORS=$((ERRORS + 1))
  ISSUES+=('{"id":"content-h1-missing","severity":"error","title":"Missing H1 tag","message":"No H1 heading found on page.","recommendation":"Include exactly one primary H1 heading."}')
elif [ "$H1_COUNT" -eq 1 ]; then
  PASSES+=('{"id":"content-h1-pass","title":"Single H1 tag present","message":"Clean heading hierarchy maintained."}')
else
  WARNINGS=$((WARNINGS + 1))
  ISSUES+=('{"id":"content-h1-multiple","severity":"warning","title":"Multiple H1 tags","message":"Found '"$H1_COUNT"' H1 headings.","recommendation":"Consolidate into a single primary H1."}')
fi

# Word count check
if [ "$WORDS" -lt 100 ]; then
  ERRORS=$((ERRORS + 1))
  ISSUES+=('{"id":"content-thin","severity":"error","title":"Thin page content","message":"Page contains only '"$WORDS"' words.","recommendation":"Add helpful, relevant content."}')
else
  PASSES+=('{"id":"content-words-pass","title":"Adequate content length","message":"Page contains '"$WORDS"' words."}')
fi

# HTTPS check
if [ "$IS_HTTPS" = "true" ]; then
  PASSES+=('{"id":"tech-https-pass","title":"Secure HTTPS active","message":"Website communicates over secure encrypted HTTPS."}')
else
  ERRORS=$((ERRORS + 1))
  ISSUES+=('{"id":"tech-not-https","severity":"error","title":"Insecure HTTP protocol","message":"Page served over unencrypted HTTP.","recommendation":"Deploy valid SSL/TLS certificates."}')
fi

SCORE=$((100 - (ERRORS * 15) - (WARNINGS * 6)))
if [ "$SCORE" -lt 10 ]; then SCORE=10; fi
if [ "$SCORE" -gt 100 ]; then SCORE=100; fi

GRADE="F"
if [ "$SCORE" -ge 95 ]; then GRADE="A+";
elif [ "$SCORE" -ge 90 ]; then GRADE="A";
elif [ "$SCORE" -ge 80 ]; then GRADE="B";
elif [ "$SCORE" -ge 70 ]; then GRADE="C";
elif [ "$SCORE" -ge 60 ]; then GRADE="D"; fi

STATUS="PASS"
if [ "$SCORE" -lt "$THRESHOLD" ]; then
  STATUS="ALERT"
fi

NOW_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

JOIN_ISSUES=$(printf ",%s" "${ISSUES[@]:-}")
JOIN_ISSUES=${JOIN_ISSUES:1}
JOIN_PASSES=$(printf ",%s" "${PASSES[@]:-}")
JOIN_PASSES=${JOIN_PASSES:1}

OUTPUT=$(cat << JSON_EOF
{
  "url": "$URL",
  "score": $SCORE,
  "grade": "$GRADE",
  "status": "$STATUS",
  "title": "$TITLE",
  "title_length": $TITLE_LEN,
  "meta_description": "$META_DESC",
  "meta_description_length": $DESC_LEN,
  "has_viewport": $VIEWPORT,
  "has_canonical": $CANONICAL,
  "canonical_url": "$CANONICAL_URL",
  "is_https": $IS_HTTPS,
  "h1_count": $H1_COUNT,
  "word_count": $WORDS,
  "response_time_ms": $ELAPSED_MS,
  "issues_count": ${#ISSUES[@]},
  "passes_count": ${#PASSES[@]},
  "issues": [$JOIN_ISSUES],
  "passes": [$JOIN_PASSES],
  "platform_url": "https://seowebchecker.com/",
  "timestamp": "$NOW_ISO"
}
JSON_EOF
)

if [ -n "$OUT_FILE" ]; then
  mkdir -p "$(dirname "$OUT_FILE")"
  echo "$OUTPUT" > "$OUT_FILE"
fi

echo "$OUTPUT"

if [ "$STATUS" = "PASS" ]; then
  exit 0
else
  exit 1
fi
EOF

  file { '/usr/local/bin/seowebchecker':
    ensure  => $seowebchecker::ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $script_content,
  }
}
