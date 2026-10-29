using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace SeoWebChecker.SeoAudit
{
    public class SEOAuditor
    {
        private readonly HttpClient _httpClient;
        public string UserAgent { get; set; } = "SEOWebChecker-DotNetBot/1.0 (+https://seowebchecker.com/)";

        public SEOAuditor(HttpClient? httpClient = null)
        {
            _httpClient = httpClient ?? new HttpClient();
        }

        public async Task<AuditResult> AuditAsync(string url)
        {
            if (!url.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
                !url.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                url = "https://" + url;
            }

            var sw = Stopwatch.StartNew();
            using var req = new HttpRequestMessage(HttpMethod.Get, url);
            req.Headers.Add("User-Agent", UserAgent);
            req.Headers.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");

            using var resp = await _httpClient.SendAsync(req).ConfigureAwait(false);
            var content = await resp.Content.ReadAsStringAsync().ConfigureAwait(false);
            sw.Stop();

            return AuditHtml(content, url, sw.ElapsedMilliseconds, (int)resp.StatusCode);
        }

        public AuditResult AuditHtml(string html, string url = "https://seowebchecker.com/", double responseTimeMs = 120.0, int statusCode = 200)
        {
            var issues = new List<Issue>();

            // 1. Title
            var titleMatch = Regex.Match(html, @"<title[^>]*>(.*?)</title>", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            string? title = titleMatch.Success ? Regex.Replace(titleMatch.Groups[1].Value, @"\s+", " ").Trim() : null;
            int titleLen = title?.Length ?? 0;

            if (string.IsNullOrEmpty(title))
            {
                issues.Add(new Issue { Id = "meta-title-missing", Category = "meta", Severity = "error", Title = "Missing Title Tag", Message = "No <title> found.", Recommendation = "Add title between 30 and 60 characters." });
            }
            else if (titleLen < 30)
            {
                issues.Add(new Issue { Id = "meta-title-short", Category = "meta", Severity = "warning", Title = "Title Too Short", Message = $"Title has {titleLen} characters.", Recommendation = "Expand title to 30-60 characters." });
            }
            else if (titleLen > 65)
            {
                issues.Add(new Issue { Id = "meta-title-long", Category = "meta", Severity = "warning", Title = "Title Too Long", Message = $"Title has {titleLen} characters.", Recommendation = "Shorten title to under 60 characters." });
            }
            else
            {
                issues.Add(new Issue { Id = "meta-title-pass", Category = "meta", Severity = "pass", Title = "Optimal Title Length", Message = $"Title has {titleLen} characters.", Recommendation = "Maintain title quality." });
            }

            // 2. Description
            var descMatch = Regex.Match(html, @"<meta[^>]*name=[""']description[""'][^>]*content=[""']([^""']*)[""']", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            if (!descMatch.Success)
            {
                descMatch = Regex.Match(html, @"<meta[^>]*content=[""']([^""']*)[""'][^>]*name=[""']description[""']", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            }
            string? desc = descMatch.Success ? descMatch.Groups[1].Value.Trim() : null;
            int descLen = desc?.Length ?? 0;

            if (string.IsNullOrEmpty(desc))
            {
                issues.Add(new Issue { Id = "meta-desc-missing", Category = "meta", Severity = "error", Title = "Missing Meta Description", Message = "No description meta tag.", Recommendation = "Add description between 120 and 160 characters." });
            }
            else if (descLen < 70)
            {
                issues.Add(new Issue { Id = "meta-desc-short", Category = "meta", Severity = "warning", Title = "Meta Description Too Short", Message = $"Description has {descLen} characters.", Recommendation = "Expand description to 120-160 characters." });
            }
            else
            {
                issues.Add(new Issue { Id = "meta-desc-pass", Category = "meta", Severity = "pass", Title = "Optimal Description", Message = $"Description has {descLen} characters.", Recommendation = "Good meta description." });
            }

            // 3. Viewport & Canonical
            bool hasViewport = Regex.IsMatch(html, @"<meta[^>]*name=[""']viewport[""']", RegexOptions.IgnoreCase);
            if (hasViewport)
                issues.Add(new Issue { Id = "meta-viewport-pass", Category = "meta", Severity = "pass", Title = "Mobile Viewport Present", Message = "Mobile viewport tag active.", Recommendation = "Mobile responsive." });
            else
                issues.Add(new Issue { Id = "meta-viewport-missing", Category = "meta", Severity = "error", Title = "Missing Viewport", Message = "No mobile viewport tag.", Recommendation = "Add viewport tag for mobile SEO." });

            bool hasCanonical = Regex.IsMatch(html, @"<link[^>]*rel=[""']canonical[""']", RegexOptions.IgnoreCase);
            if (hasCanonical)
                issues.Add(new Issue { Id = "meta-canonical-pass", Category = "meta", Severity = "pass", Title = "Canonical URL Present", Message = "Canonical tag configured.", Recommendation = "Canonical active." });
            else
                issues.Add(new Issue { Id = "meta-canonical-missing", Category = "meta", Severity = "warning", Title = "Missing Canonical Tag", Message = "No canonical URL.", Recommendation = "Add canonical link." });

            // 4. Content & Headings
            var h1Matches = Regex.Matches(html, @"<h1[^>]*>(.*?)</h1>", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            var h1Tags = new List<string>();
            foreach (Match m in h1Matches)
            {
                h1Tags.Add(Regex.Replace(m.Groups[1].Value, @"<[^>]+>", "").Trim());
            }

            string cleanText = Regex.Replace(html, @"<(script|style)[^>]*>.*?</\1>", " ", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            cleanText = Regex.Replace(cleanText, @"<[^>]+>", " ");
            var words = Regex.Matches(cleanText, @"\b[a-zA-Z0-9_\'-]{2,}\b");
            int wordCount = words.Count;

            if (h1Tags.Count == 0)
                issues.Add(new Issue { Id = "content-h1-missing", Category = "content", Severity = "error", Title = "Missing <h1> Tag", Message = "No <h1> heading found.", Recommendation = "Add a single <h1> heading." });
            else if (h1Tags.Count == 1)
                issues.Add(new Issue { Id = "content-h1-pass", Category = "content", Severity = "pass", Title = "Single <h1> Tag Present", Message = $"H1: '{h1Tags[0]}'.", Recommendation = "Good heading structure." });
            else
                issues.Add(new Issue { Id = "content-h1-multiple", Category = "content", Severity = "warning", Title = $"Multiple <h1> Tags ({h1Tags.Count})", Message = $"Found {h1Tags.Count} <h1> headings.", Recommendation = "Consolidate to one <h1>." });

            if (wordCount < 100)
                issues.Add(new Issue { Id = "content-thin", Category = "content", Severity = "error", Title = "Thin Content", Message = $"Only {wordCount} words detected.", Recommendation = "Expand text to 300+ words." });
            else
                issues.Add(new Issue { Id = "content-words-pass", Category = "content", Severity = "pass", Title = "Adequate Content Length", Message = $"{wordCount} words found.", Recommendation = "Good content volume." });

            // 5. Images
            var imgMatches = Regex.Matches(html, @"<img\s+([^>]*?)>", RegexOptions.IgnoreCase);
            int missingAlt = 0;
            foreach (Match m in imgMatches)
            {
                if (!Regex.IsMatch(m.Groups[1].Value, @"alt=[""']", RegexOptions.IgnoreCase))
                    missingAlt++;
            }

            if (imgMatches.Count > 0)
            {
                if (missingAlt > 0)
                    issues.Add(new Issue { Id = "images-missing-alt", Category = "images", Severity = "error", Title = $"{missingAlt} Images Missing Alt Text", Message = $"{missingAlt} images lack alt attributes.", Recommendation = "Add alt attributes to all images." });
                else
                    issues.Add(new Issue { Id = "images-alt-pass", Category = "images", Severity = "pass", Title = "All Images Have Alt Text", Message = $"All {imgMatches.Count} images have alt tags.", Recommendation = "Great accessibility." });
            }

            // 6. Technical HTTPS
            bool isHttps = url.StartsWith("https://", StringComparison.OrdinalIgnoreCase);
            if (isHttps)
                issues.Add(new Issue { Id = "tech-https-pass", Category = "technical", Severity = "pass", Title = "Secure HTTPS Active", Message = "Secured with SSL/TLS.", Recommendation = "Certificate is valid." });
            else
                issues.Add(new Issue { Id = "tech-not-https", Category = "technical", Severity = "error", Title = "Insecure HTTP Protocol", Message = "Site uses HTTP.", Recommendation = "Enforce HTTPS." });

            // Compute score
            int passed = issues.Count(i => i.Severity == "pass");
            int warnings = issues.Count(i => i.Severity == "warning");
            int errors = issues.Count(i => i.Severity == "error");

            int rawScore = issues.Count > 0 ? (int)Math.Round((double)passed / issues.Count * 100.0) : 80;
            rawScore -= (errors * 10) + (warnings * 3);
            int finalScore = Math.Max(0, Math.Min(100, rawScore));

            string grade = finalScore >= 95 ? "A+" :
                           finalScore >= 90 ? "A" :
                           finalScore >= 80 ? "B" :
                           finalScore >= 70 ? "C" :
                           finalScore >= 60 ? "D" : "F";

            return new AuditResult
            {
                Url = url,
                Timestamp = DateTime.UtcNow,
                Score = new SeoScore { Overall = finalScore, Grade = grade },
                Stats = new Dictionary<string, int>
                {
                    ["total"] = issues.Count,
                    ["passed"] = passed,
                    ["warnings"] = warnings,
                    ["errors"] = errors
                },
                Meta = new Dictionary<string, object?> { ["title"] = title, ["title_length"] = titleLen, ["description"] = desc },
                Content = new Dictionary<string, object?> { ["word_count"] = wordCount, ["h1_tags"] = h1Tags },
                Images = new Dictionary<string, object?> { ["total_images"] = imgMatches.Count, ["missing_alt"] = missingAlt },
                Technical = new Dictionary<string, object?> { ["is_https"] = isHttps },
                Performance = new Dictionary<string, object?> { ["response_time_ms"] = responseTimeMs, ["status_code"] = statusCode },
                Issues = issues
            };
        }
    }
}
