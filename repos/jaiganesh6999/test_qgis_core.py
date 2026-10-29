import sys
sys.path.insert(0, 'qgis-plugin/seowebchecker')
from seowebchecker_core import GeoSeoAuditor

def test_engine():
    auditor = GeoSeoAuditor()
    sample_html = """<!DOCTYPE html>
<html>
<head>
  <title>SEOWebChecker -- Technical SEO Audit and Analyzer</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Audit technical SEO, on-page tags, and Core Web Vitals with SEOWebChecker in seconds.">
  <link rel="canonical" href="https://seowebchecker.com/">
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "LocalBusiness",
    "name": "SEOWebChecker HQ",
    "geo": {
      "@type": "GeoCoordinates",
      "latitude": 37.7749,
      "longitude": -122.4194
    },
    "address": {
      "@type": "PostalAddress",
      "streetAddress": "100 Market St",
      "addressLocality": "San Francisco",
      "postalCode": "94105",
      "addressCountry": "US"
    }
  }
  </script>
</head>
<body>
  <h1>Technical SEO Audit Tool</h1>
  <p>Here is an informative paragraph with sufficient words describing our SEO audit tool and on-page analyzer in detail to verify that word count checks pass reliably without triggering thin content warnings on test runs. We ensure that our comprehensive evaluation accurately assesses on-page optimization, content volume, mobile readiness, and heading hierarchies to provide search engines with complete indexation clarity and maximum visibility across all modern web properties and platforms.</p>
  <p>In addition, technical audits must evaluate meta descriptions, canonical declarations, document titles, schema metadata, performance metrics, and accessibility indicators to help web developers and site owners optimize organic user experience, crawl budgets, indexing efficiency, and overall search visibility.</p>
</body>
</html>"""

    res = auditor.audit_html(sample_html, url="https://seowebchecker.com/")
    print(f"URL: {res['url']}")
    print(f"Score: {res['score']}/100 ({res['grade']})")
    print(f"Status: {res['status']}")
    print(f"Has Geo: {res['has_geo']}")
    print(f"Coordinates: Lat {res['latitude']}, Lon {res['longitude']}")
    print(f"Business: {res['business_name']}")
    print(f"Address: {res['address']}")
    print(f"Passes: {res['passes_count']}, Issues: {res['issues_count']}")

    assert res['score'] >= 95, "Optimal page should have score >= 95"
    assert res['has_geo'] == True, "Schema.org GeoCoordinates must be detected"
    assert res['latitude'] == 37.7749, "Latitude must match"
    assert res['longitude'] == -122.4194, "Longitude must match"
    print("\n>>> ALL TESTS PASSED SUCCESSFULLY! <<<")

if __name__ == '__main__':
    test_engine()
