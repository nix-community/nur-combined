package com.seowebchecker;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Lightweight SEO Auditor in pure Java.
 * Official Website: https://seowebchecker.com/
 */
public class SEOAuditor {
    private final String userAgent;
    private final int timeoutMs;

    public SEOAuditor() {
        this("SEOWebChecker-JavaBot/1.0 (+https://seowebchecker.com/)", 15000);
    }

    public SEOAuditor(String userAgent, int timeoutMs) {
        this.userAgent = userAgent;
        this.timeoutMs = timeoutMs;
    }

    public AuditResult audit(String targetUrl) throws Exception {
        if (!targetUrl.startsWith("http://") && !targetUrl.startsWith("https://")) {
            targetUrl = "https://" + targetUrl;
        }

        URL urlObj = new URL(targetUrl);
        HttpURLConnection conn = (HttpURLConnection) urlObj.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("User-Agent", userAgent);
        conn.setRequestProperty("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
        conn.setConnectTimeout(timeoutMs);
        conn.setReadTimeout(timeoutMs);

        long start = System.currentTimeMillis();
        conn.connect();
        int status = conn.getResponseCode();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line).append("\n");
            }
        }
        long elapsed = System.currentTimeMillis() - start;

        return auditHtml(sb.toString(), targetUrl, elapsed, status);
    }

    public AuditResult auditHtml(String html, String url, long responseTimeMs, int statusCode) {
        List<Issue> issues = new ArrayList<>();
        Map<String, Object> metadata = new HashMap<>();

        // 1. Title
        Pattern titlePat = Pattern.compile("(?is)<title[^>]*>(.*?)</title>");
        Matcher titleMat = titlePat.matcher(html);
        String title = null;
        if (titleMat.find()) {
            title = titleMat.group(1).replaceAll("\\s+", " ").trim();
        }
        int titleLen = (title != null) ? title.length() : 0;
        metadata.put("title", title);

        if (title == null || title.isEmpty()) {
            issues.add(new Issue("meta-title-missing", "meta", "error", "Missing Title Tag", "No <title> found.", "Add a title between 30 and 60 characters."));
        } else if (titleLen < 30) {
            issues.add(new Issue("meta-title-short", "meta", "warning", "Title Too Short", "Title has " + titleLen + " characters.", "Expand title to 30-60 characters."));
        } else if (titleLen > 65) {
            issues.add(new Issue("meta-title-long", "meta", "warning", "Title Too Long", "Title has " + titleLen + " characters.", "Shorten title to under 60 characters."));
        } else {
            issues.add(new Issue("meta-title-pass", "meta", "pass", "Optimal Title Length", "Title length is " + titleLen + " characters.", "Maintain title quality."));
        }

        // 2. Viewport
        Pattern vpPat = Pattern.compile("(?i)<meta[^>]*name=[\"']viewport[\"']");
        if (vpPat.matcher(html).find()) {
            issues.add(new Issue("meta-viewport-pass", "meta", "pass", "Mobile Viewport Present", "Mobile viewport is active.", "Mobile responsive."));
        } else {
            issues.add(new Issue("meta-viewport-missing", "meta", "error", "Missing Viewport", "No mobile viewport detected.", "Add mobile viewport meta tag."));
        }

        // 3. Headings H1
        Pattern h1Pat = Pattern.compile("(?is)<h1[^>]*>(.*?)</h1>");
        Matcher h1Mat = h1Pat.matcher(html);
        int h1Count = 0;
        while (h1Mat.find()) {
            h1Count++;
        }
        if (h1Count == 0) {
            issues.add(new Issue("content-h1-missing", "content", "error", "Missing <h1> Tag", "No <h1> heading found.", "Add a single <h1> heading."));
        } else if (h1Count == 1) {
            issues.add(new Issue("content-h1-pass", "content", "pass", "Single <h1> Tag Configured", "Single primary heading detected.", "Good hierarchy."));
        } else {
            issues.add(new Issue("content-h1-multiple", "content", "warning", "Multiple <h1> Tags (" + h1Count + ")", "Found multiple <h1> headings.", "Consolidate down to a single <h1>."));
        }

        // 4. HTTPS
        boolean isHttps = url.toLowerCase().startsWith("https://");
        if (isHttps) {
            issues.add(new Issue("tech-https-pass", "technical", "pass", "Secure HTTPS Active", "Encrypted connection.", "SSL certificate active."));
        } else {
            issues.add(new Issue("tech-not-https", "technical", "error", "Insecure HTTP Protocol", "Site does not use HTTPS.", "Enforce HTTPS."));
        }

        // Score computation
        long passed = issues.stream().filter(i -> "pass".equalsIgnoreCase(i.getSeverity())).count();
        long warnings = issues.stream().filter(i -> "warning".equalsIgnoreCase(i.getSeverity())).count();
        long errors = issues.stream().filter(i -> "error".equalsIgnoreCase(i.getSeverity())).count();

        int total = issues.size();
        int rawScore = (total > 0) ? (int) Math.round(((double) passed / total) * 100.0) : 80;
        rawScore -= (errors * 10) + (warnings * 3);
        int finalScore = Math.max(0, Math.min(100, rawScore));

        String grade = (finalScore >= 95) ? "A+" :
                       (finalScore >= 90) ? "A" :
                       (finalScore >= 80) ? "B" :
                       (finalScore >= 70) ? "C" :
                       (finalScore >= 60) ? "D" : "F";

        return new AuditResult(url, finalScore, grade, issues, metadata);
    }
}
