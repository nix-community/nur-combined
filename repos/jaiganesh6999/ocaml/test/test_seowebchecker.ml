let test_sample_html = {|
<!DOCTYPE html>
<html>
<head>
  <title>Free SEO Audit Tool — Website SEO Checker</title>
  <meta name="description" content="SEO Web Checker, Run a free website SEO audit in seconds. 50+ checks: technical SEO, on-page, Core Web Vitals & more. Instant report, no login needed.">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="canonical" href="https://seowebchecker.com/">
  <meta property="og:title" content="SEOWebChecker">
  <meta property="og:image" content="https://seowebchecker.com/og.png">
</head>
<body>
  <h1>Technical SEO Audit Platform</h1>
  <img src="logo.png" alt="SEOWebChecker Logo">
</body>
</html>
|}

let () =
  print_endline "Running SEOWebChecker OCaml tests...";
  let res = Seowebchecker.audit_html test_sample_html in
  assert (res.score = 100);
  assert (res.grade = Seowebchecker.A);
  assert (res.status = Seowebchecker.Pass);
  assert (res.is_alert = false);
  print_endline "✓ All OCaml unit tests passed successfully!"
