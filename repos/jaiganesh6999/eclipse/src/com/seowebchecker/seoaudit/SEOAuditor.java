package com.seowebchecker.seoaudit;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * SEOWebChecker Core Auditing Engine for Eclipse IDE.
 * Analyzes HTML, JSP, JSF, PHP, React templates for on-page SEO compliance.
 * Official Website: https://seowebchecker.com/
 */
public class SEOAuditor {

    public static class AuditResult {
        public int score;
        public String grade;
        public String status;
        public String title;
        public String metaDescription;
        public List<String> issues = new ArrayList<>();
        public List<String> passes = new ArrayList<>();
    }

    public static AuditResult audit(String html) {
        AuditResult res = new AuditResult();
        int score = 100;

        // 1. Title Tag
        Pattern titlePattern = Pattern.compile("<title[^>]*>(.*?)</title>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
        Matcher titleMatcher = titlePattern.matcher(html);
        if (titleMatcher.find()) {
            res.title = titleMatcher.group(1).trim();
            int len = res.title.length();
            if (len < 30) {
                res.issues.add("Title tag too short (" + len + " chars, recommended: 30-60) [-5 pts]");
                score -= 5;
            } else if (len > 60) {
                res.issues.add("Title tag exceeds 60 chars (" + len + " chars, truncation risk) [-5 pts]");
                score -= 5;
            } else {
                res.passes.add("Title tag length is optimal (" + len + " chars)");
            }
        } else {
            res.issues.add("Missing <title> tag [-20 pts]");
            score -= 20;
        }

        // 2. Meta Description
        Pattern descPattern = Pattern.compile("<meta[^>]*name=[\"']description[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>", Pattern.CASE_INSENSITIVE);
        Matcher descMatcher = descPattern.matcher(html);
        if (descMatcher.find()) {
            res.metaDescription = descMatcher.group(1).trim();
            int len = res.metaDescription.length();
            if (len < 70) {
                res.issues.add("Meta description too short (" + len + " chars, recommended: 70-160) [-5 pts]");
                score -= 5;
            } else if (len > 160) {
                res.issues.add("Meta description exceeds 160 chars (" + len + " chars) [-5 pts]");
                score -= 5;
            } else {
                res.passes.add("Meta description length is optimal (" + len + " chars)");
            }
        } else {
            res.issues.add("Missing meta description tag [-15 pts]");
            score -= 15;
        }

        // 3. Heading Hierarchy (H1 check)
        Pattern h1Pattern = Pattern.compile("<h1[^>]*>", Pattern.CASE_INSENSITIVE);
        Matcher h1Matcher = h1Pattern.matcher(html);
        int h1Count = 0;
        while (h1Matcher.find()) {
            h1Count++;
        }
        if (h1Count == 0) {
            res.issues.add("Missing <h1> tag [-15 pts]");
            score -= 15;
        } else if (h1Count > 1) {
            res.issues.add("Multiple <h1> tags detected (" + h1Count + " found) [-10 pts]");
            score -= 10;
        } else {
            res.passes.add("Exactly one <h1> heading present");
        }

        // 4. Viewport Tag
        if (Pattern.compile("<meta[^>]*name=[\"']viewport[\"']", Pattern.CASE_INSENSITIVE).matcher(html).find()) {
            res.passes.add("Mobile viewport meta tag configured");
        } else {
            res.issues.add("Missing mobile viewport meta tag [-15 pts]");
            score -= 15;
        }

        // 5. Canonical Link Tag
        if (Pattern.compile("<link[^>]*rel=[\"']canonical[\"']", Pattern.CASE_INSENSITIVE).matcher(html).find()) {
            res.passes.add("Canonical link tag present");
        } else {
            res.issues.add("Missing canonical link tag [-10 pts]");
            score -= 10;
        }

        // 6. Image Alt Attributes
        Pattern imgPattern = Pattern.compile("<img[^>]*>", Pattern.CASE_INSENSITIVE);
        Matcher imgMatcher = imgPattern.matcher(html);
        int missingAlt = 0;
        int totalImgs = 0;
        while (imgMatcher.find()) {
            totalImgs++;
            String tag = imgMatcher.group();
            if (!tag.toLowerCase().contains("alt=")) {
                missingAlt++;
            }
        }
        if (missingAlt > 0) {
            res.issues.add(missingAlt + " image(s) missing alt attribute [-10 pts]");
            score -= 10;
        } else if (totalImgs > 0) {
            res.passes.add("All " + totalImgs + " images include alt attributes");
        }

        // 7. OpenGraph Social Sharing
        boolean hasOgTitle = Pattern.compile("<meta[^>]*property=[\"']og:title[\"']", Pattern.CASE_INSENSITIVE).matcher(html).find();
        boolean hasOgImage = Pattern.compile("<meta[^>]*property=[\"']og:image[\"']", Pattern.CASE_INSENSITIVE).matcher(html).find();
        if (hasOgTitle && hasOgImage) {
            res.passes.add("OpenGraph social cards configured (og:title, og:image)");
        } else {
            res.issues.add("Incomplete OpenGraph tags [-5 pts]");
            score -= 5;
        }

        res.score = Math.max(0, score);
        if (res.score >= 90) res.grade = "A";
        else if (res.score >= 80) res.grade = "B";
        else if (res.score >= 70) res.grade = "C";
        else if (res.score >= 60) res.grade = "D";
        else res.grade = "F";

        res.status = res.score >= 85 ? "PASS" : "ALERT";
        return res;
    }
}
