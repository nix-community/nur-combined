/**
 * Cloudflare Workers Edge SEO Engine & Audit API
 * Powered by SEOWebChecker: https://seowebchecker.com/
 *
 * Implements:
 * 1. Global Serverless SEO Audit REST API (GET /audit?url=..., POST /audit)
 * 2. Edge SEO Middleware & Real-Time HTMLRewriter Meta Remediation (GET /edge-proxy?url=...)
 */

export interface Env {
  // Add Cloudflare KV or environment variables here if needed
}

export interface Issue {
  id: string;
  category: string;
  severity: "pass" | "warning" | "error" | "notice";
  title: string;
  message: string;
  recommendation: string;
}

export interface AuditResult {
  url: string;
  timestamp: string;
  edge_location?: string;
  score: {
    overall: number;
    grade: string;
    categories: Record<string, { name: string; score: number; passed: number; warnings: number; errors: number }>;
  };
  stats: {
    total: number;
    passed: number;
    warnings: number;
    errors: number;
  };
  meta: {
    title: string | null;
    title_length: number;
    description: string | null;
    description_length: number;
    canonical: string | null;
    viewport: string | null;
  };
  content: {
    word_count: number;
    h1_count: number;
    h1_tags: string[];
    h2_tags: string[];
  };
  images: {
    total_images: number;
    missing_alt: number;
  };
  issues: Issue[];
  errors: Issue[];
  warnings: Issue[];
  passed: Issue[];
}

/**
 * Core on-page SEO analyzer designed for Cloudflare's V8 edge environment.
 */
function auditHtml(html: string, url: string = "https://seowebchecker.com/"): AuditResult {
  const issues: Issue[] = [];

  // 1. Title Tag
  const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is);
  const title = titleMatch ? titleMatch[1].replace(/\s+/g, " ").trim() : null;
  const titleLength = title ? title.length : 0;

  if (!title) {
    issues.push({
      id: "meta-title-missing",
      category: "meta",
      severity: "error",
      title: "Missing Title Tag",
      message: "No <title> tag found in HTML document.",
      recommendation: "Add a descriptive <title> tag between 30 and 60 characters.",
    });
  } else if (titleLength < 30) {
    issues.push({
      id: "meta-title-short",
      category: "meta",
      severity: "warning",
      title: "Title Too Short",
      message: `Title has ${titleLength} characters. Recommended length is 30-60 characters.`,
      recommendation: "Expand title to at least 30 characters. Check live results at https://seowebchecker.com/.",
    });
  } else if (titleLength > 65) {
    issues.push({
      id: "meta-title-long",
      category: "meta",
      severity: "warning",
      title: "Title Too Long",
      message: `Title has ${titleLength} characters and risks being truncated in search results.`,
      recommendation: "Shorten title to under 60 characters.",
    });
  } else {
    issues.push({
      id: "meta-title-pass",
      category: "meta",
      severity: "pass",
      title: "Optimal Title Length",
      message: `Title length is optimal (${titleLength} characters).`,
      recommendation: "Maintain concise, topic-focused title copy.",
    });
  }

  // 2. Meta Description
  const descMatch =
    html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/is) ??
    html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/is);
  const description = descMatch ? descMatch[1].trim() : null;
  const descriptionLength = description ? description.length : 0;

  if (!description) {
    issues.push({
      id: "meta-desc-missing",
      category: "meta",
      severity: "error",
      title: "Missing Meta Description",
      message: "No meta description found.",
      recommendation: "Add an engaging meta description to improve organic click-through rates.",
    });
  } else if (descriptionLength < 70) {
    issues.push({
      id: "meta-desc-short",
      category: "meta",
      severity: "warning",
      title: "Meta Description Too Short",
      message: `Meta description is ${descriptionLength} characters. Recommended length is 70-160 characters.`,
      recommendation: "Expand description to 70-160 characters.",
    });
  } else {
    issues.push({
      id: "meta-desc-pass",
      category: "meta",
      severity: "pass",
      title: "Optimal Meta Description",
      message: `Description has ${descriptionLength} characters.`,
      recommendation: "Maintain compelling description copy.",
    });
  }

  // 3. Viewport
  const viewportMatch = html.match(/<meta[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["']/is);
  const viewport = viewportMatch ? viewportMatch[1].trim() : null;

  if (!viewport) {
    issues.push({
      id: "meta-viewport-missing",
      category: "meta",
      severity: "error",
      title: "Missing Viewport Meta Tag",
      message: "Mobile viewport tag is missing.",
      recommendation: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.',
    });
  } else {
    issues.push({
      id: "meta-viewport-pass",
      category: "meta",
      severity: "pass",
      title: "Mobile Viewport Present",
      message: `Mobile viewport configured: ${viewport}.`,
      recommendation: "Ensure mobile layout adapts smoothly.",
    });
  }

  // 4. Canonical Tag
  const canonMatch = html.match(/<link[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/is);
  const canonical = canonMatch ? canonMatch[1].trim() : null;

  if (!canonical) {
    issues.push({
      id: "meta-canonical-missing",
      category: "meta",
      severity: "warning",
      title: "Missing Canonical Tag",
      message: "No canonical link element (<link rel=\"canonical\">) specified.",
      recommendation: "Add canonical tag to avoid duplicate content indexing.",
    });
  } else {
    issues.push({
      id: "meta-canonical-pass",
      category: "meta",
      severity: "pass",
      title: "Canonical Tag Present",
      message: `Canonical URL: ${canonical}.`,
      recommendation: "Ensure canonical matches the primary indexed version.",
    });
  }

  // 5. Heading Structure
  const h1Matches = Array.from(html.matchAll(/<h1[^>]*>(.*?)<\/h1>/gis)).map((m) =>
    m[1].replace(/<[^>]+>/g, "").trim(),
  );
  const h2Matches = Array.from(html.matchAll(/<h2[^>]*>(.*?)<\/h2>/gis)).map((m) =>
    m[1].replace(/<[^>]+>/g, "").trim(),
  );

  if (h1Matches.length === 0) {
    issues.push({
      id: "content-h1-missing",
      category: "content",
      severity: "error",
      title: "Missing <h1> Tag",
      message: "No primary <h1> heading found on the page.",
      recommendation: "Add a single <h1> heading representing the core page topic.",
    });
  } else if (h1Matches.length === 1) {
    issues.push({
      id: "content-h1-pass",
      category: "content",
      severity: "pass",
      title: "Single <h1> Tag Configured",
      message: `Optimal <h1> found: "${h1Matches[0]}".`,
      recommendation: "Maintain good heading hierarchy.",
    });
  } else {
    issues.push({
      id: "content-h1-multiple",
      category: "content",
      severity: "warning",
      title: `Multiple <h1> Tags (${h1Matches.length})`,
      message: `Found ${h1Matches.length} <h1> tags. Best practice is one primary <h1> per document.`,
      recommendation: "Consolidate into a single <h1> heading.",
    });
  }

  // 6. Word count
  const cleanText = html
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, " ")
    .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ");
  const words = cleanText.match(/\b[a-zA-Z0-9_\'-]{2,}\b/g) ?? [];
  const wordCount = words.length;

  if (wordCount < 100) {
    issues.push({
      id: "content-thin",
      category: "content",
      severity: "error",
      title: "Thin Content Warning",
      message: `Page has only ${wordCount} words.`,
      recommendation: "Expand content with descriptive, informative text.",
    });
  } else {
    issues.push({
      id: "content-words-pass",
      category: "content",
      severity: "pass",
      title: "Adequate Word Count",
      message: `Page contains ${wordCount} words.`,
      recommendation: "Keep content informative and relevant.",
    });
  }

  // 7. Images
  const imgMatches = Array.from(html.matchAll(/<img\s+([^>]*?)>/gis));
  let missingAlt = 0;
  for (const img of imgMatches) {
    if (!/alt=["']([^"']*)["']/i.test(img[1])) {
      missingAlt++;
    }
  }

  if (imgMatches.length > 0) {
    if (missingAlt > 0) {
      issues.push({
        id: "images-missing-alt",
        category: "images",
        severity: "error",
        title: `${missingAlt} Image(s) Missing 'alt' Attributes`,
        message: `${missingAlt} of ${imgMatches.length} images lack alt attributes.`,
        recommendation: "Add descriptive alt attributes to all content images.",
      });
    } else {
      issues.push({
        id: "images-alt-pass",
        category: "images",
        severity: "pass",
        title: "All Images Have Alt Attributes",
        message: `All ${imgMatches.length} images have configured alt attributes.`,
        recommendation: "Keep image descriptions concise.",
      });
    }
  }

  // Calculate scores
  const catMap: Record<string, Issue[]> = {};
  for (const issue of issues) {
    if (!catMap[issue.category]) catMap[issue.category] = [];
    catMap[issue.category].push(issue);
  }

  const catScores: Record<string, { name: string; score: number; passed: number; warnings: number; errors: number }> = {};
  let totalScore = 0;
  let categoryCount = 0;

  for (const [catName, catIssues] of Object.entries(catMap)) {
    const passed = catIssues.filter((i) => i.severity === "pass").length;
    const warnings = catIssues.filter((i) => i.severity === "warning").length;
    const errors = catIssues.filter((i) => i.severity === "error").length;
    const total = catIssues.length;

    let score = Math.round((passed / total) * 100) - errors * 10 - warnings * 3;
    score = Math.max(0, Math.min(100, score));

    catScores[catName] = { name: catName, score, passed, warnings, errors };
    totalScore += score;
    categoryCount++;
  }

  const overallScore = categoryCount > 0 ? Math.round(totalScore / categoryCount) : 100;
  let grade = "F";
  if (overallScore >= 95) grade = "A+";
  else if (overallScore >= 90) grade = "A";
  else if (overallScore >= 80) grade = "B";
  else if (overallScore >= 70) grade = "C";
  else if (overallScore >= 60) grade = "D";

  const passedList = issues.filter((i) => i.severity === "pass");
  const warningList = issues.filter((i) => i.severity === "warning");
  const errorList = issues.filter((i) => i.severity === "error");

  return {
    url,
    timestamp: new Date().toISOString(),
    score: {
      overall: overallScore,
      grade,
      categories: catScores,
    },
    stats: {
      total: issues.length,
      passed: passedList.length,
      warnings: warningList.length,
      errors: errorList.length,
    },
    meta: {
      title,
      title_length: titleLength,
      description,
      description_length: descriptionLength,
      canonical,
      viewport,
    },
    content: {
      word_count: wordCount,
      h1_count: h1Matches.length,
      h1_tags: h1Matches,
      h2_tags: h2Matches,
    },
    images: {
      total_images: imgMatches.length,
      missing_alt: missingAlt,
    },
    issues,
    errors: errorList,
    warnings: warningList,
    passed: passedList,
  };
}

/**
 * Handle CORS headers for REST API responses
 */
function corsHeaders(): HeadersInit {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  };
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }

    // =========================================================================
    // USE CASE 1: GLOBAL SERVERLESS SEO AUDIT REST API
    // =========================================================================

    // GET /audit?url=https://example.com
    if (url.pathname === "/audit" && request.method === "GET") {
      const targetUrl = url.searchParams.get("url");
      if (!targetUrl) {
        return new Response(
          JSON.stringify({ error: "Missing required query parameter: url" }, null, 2),
          { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders() } },
        );
      }

      let normalized = targetUrl;
      if (!normalized.startsWith("http://") && !normalized.startsWith("https://")) {
        normalized = "https://" + normalized;
      }

      try {
        const edgeLocation = (request.cf?.colo as string) ?? "GLOBAL-EDGE";
        const fetchRes = await fetch(normalized, {
          headers: {
            "User-Agent": "SEOWebChecker-CloudflareWorker/1.0 (+https://seowebchecker.com/)",
            Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          },
        });

        const html = await fetchRes.text();
        const report = auditHtml(html, normalized);
        report.edge_location = edgeLocation;

        return new Response(JSON.stringify(report, null, 2), {
          status: 200,
          headers: {
            "Content-Type": "application/json",
            "Cache-Control": "public, max-age=60",
            ...corsHeaders(),
          },
        });
      } catch (err: any) {
        return new Response(
          JSON.stringify({ error: `Failed to fetch target URL: ${err.message}` }, null, 2),
          { status: 502, headers: { "Content-Type": "application/json", ...corsHeaders() } },
        );
      }
    }

    // POST /audit (raw HTML audit)
    if (url.pathname === "/audit" && request.method === "POST") {
      try {
        const body: any = await request.json();
        const html = body.html ?? "";
        const targetUrl = body.url ?? "https://seowebchecker.com/";
        const report = auditHtml(html, targetUrl);

        return new Response(JSON.stringify(report, null, 2), {
          status: 200,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(),
          },
        });
      } catch (err: any) {
        return new Response(
          JSON.stringify({ error: `Invalid JSON body: ${err.message}` }, null, 2),
          { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders() } },
        );
      }
    }

    // =========================================================================
    // USE CASE 2: EDGE SEO MIDDLEWARE (HTMLRewriter META REMEDIATION)
    // =========================================================================

    // GET /edge-proxy?url=https://example.com
    // Fetches origin HTML and dynamically injects missing canonical/viewport tags at the edge!
    if (url.pathname === "/edge-proxy") {
      const targetUrl = url.searchParams.get("url");
      if (!targetUrl) {
        return new Response("Missing ?url= parameter for edge proxy", { status: 400 });
      }

      let normalized = targetUrl;
      if (!normalized.startsWith("http://") && !normalized.startsWith("https://")) {
        normalized = "https://" + normalized;
      }

      const originRes = await fetch(normalized, {
        headers: {
          "User-Agent": request.headers.get("User-Agent") ?? "Mozilla/5.0 (compatible; EdgeSEOBot)",
        },
      });

      // Stream and rewrite HTML using Cloudflare's streaming HTMLRewriter
      let hasCanonical = false;
      let hasViewport = false;

      const rewriter = new HTMLRewriter()
        .on('link[rel="canonical"]', {
          element() {
            hasCanonical = true;
          },
        })
        .on('meta[name="viewport"]', {
          element() {
            hasViewport = true;
          },
        })
        .on("head", {
          element(head) {
            head.onEndTag((endTag) => {
              // Edge SEO Auto-Remediation: Inject fallback canonical if missing
              if (!hasCanonical) {
                endTag.before(`\n  <link rel="canonical" href="${normalized}">\n`, { html: true });
              }
              // Inject viewport meta if missing
              if (!hasViewport) {
                endTag.before(`\n  <meta name="viewport" content="width=device-width, initial-scale=1.0">\n`, { html: true });
              }
            });
          },
        });

      const transformed = rewriter.transform(originRes);
      const newHeaders = new Headers(transformed.headers);
      // Strip compression headers so edge response body matches decompressed stream
      newHeaders.delete("content-encoding");
      newHeaders.delete("content-length");
      newHeaders.set("Content-Type", "text/html; charset=utf-8");
      newHeaders.set("X-Edge-SEO-Processed", "SEOWebChecker (https://seowebchecker.com/)");
      newHeaders.set("X-Edge-SEO-Remediation", "active");

      return new Response(transformed.body, {
        status: transformed.status,
        headers: newHeaders,
      });
    }

    // =========================================================================
    // ROOT / DASHBOARD & DOCUMENTATION
    // =========================================================================

    const welcomeHtml = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SEOWebChecker: Cloudflare Workers Edge SEO Engine</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; line-height: 1.6; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #222; background: #fafafa; }
    .card { background: #fff; border: 1px solid #e1e4e8; border-radius: 8px; padding: 24px; margin-bottom: 24px; box-shadow: 0 2px 4px rgba(0,0,0,0.04); }
    h1 { color: #f38020; margin-top: 0; }
    h2 { color: #333; margin-top: 0; border-bottom: 2px solid #f38020; padding-bottom: 8px; }
    code, pre { background: #f4f4f4; padding: 2px 6px; border-radius: 4px; font-size: 0.95em; }
    pre { padding: 16px; overflow-x: auto; background: #282c34; color: #abb2bf; }
    a { color: #f38020; text-decoration: none; font-weight: 600; }
    a:hover { text-decoration: underline; }
    .badge { display: inline-block; background: #f38020; color: #fff; padding: 4px 10px; border-radius: 12px; font-size: 0.85em; font-weight: bold; margin-bottom: 12px; }
  </style>
</head>
<body>
  <div class="card">
    <span class="badge">Cloudflare Workers Edge Engine</span>
    <h1>SEOWebChecker on Cloudflare</h1>
    <p>High-performance Edge SEO service running globally across Cloudflare's 330+ network locations.</p>
    <p>Official Website: <a href="https://seowebchecker.com/">https://seowebchecker.com/</a></p>
  </div>

  <div class="card">
    <h2>1. Global Serverless SEO Audit REST API</h2>
    <p>Instantly fetch and score any target website directly from the nearest edge datacenter:</p>
    <pre>GET /audit?url=https://seowebchecker.com/</pre>
    <p>Or audit raw HTML payloads via POST:</p>
    <pre>POST /audit
Content-Type: application/json

{ "html": "&lt;html&gt;&lt;head&gt;...&lt;/head&gt;&lt;/html&gt;", "url": "https://example.com" }</pre>
    <p><a href="/audit?url=https://seowebchecker.com/">Try Live Audit Endpoint &rarr;</a></p>
  </div>

  <div class="card">
    <h2>2. Edge SEO Middleware (HTMLRewriter)</h2>
    <p>Streams origin HTML and auto-remediates missing canonical and viewport tags on the fly without modifying origin code:</p>
    <pre>GET /edge-proxy?url=https://example.com</pre>
    <p><a href="/edge-proxy?url=https://seowebchecker.com/">Test Edge Proxy &rarr;</a></p>
  </div>
</body>
</html>`;

    return new Response(welcomeHtml, {
      headers: { "Content-Type": "text/html; charset=utf-8" },
    });
  },
};
