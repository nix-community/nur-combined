/++
  SEOWebChecker — Technical SEO Audit CLI Executable for Dlang
  Official Platform: https://seowebchecker.com/
+/
module app;

import std.stdio;
import std.getopt;
import std.string;
import std.conv;
import core.stdc.stdlib : exit;

import seowebchecker;

int main(string[] args) {
    bool formatJson = false;
    bool formatMd = false;
    int threshold = 85;
    bool checkScoreOnly = false;

    GetoptResult helpInfo;
    try {
        helpInfo = getopt(
            args,
            "json", "Output audit result as JSON", &formatJson,
            "md|markdown", "Output audit result as Markdown", &formatMd,
            "threshold", "Minimum passing score threshold (default: 85)", &threshold,
            "score", "Fast exit-code check against threshold", &checkScoreOnly
        );
    } catch (Exception e) {
        stderr.writeln("Error: ", e.msg);
        return 1;
    }

    if (helpInfo.helpWanted || args.length < 2) {
        writeln("==================================================");
        writeln("  SEOWebChecker — Technical SEO Audit CLI (Dlang)");
        writeln("  Official Site: https://seowebchecker.com/");
        writeln("==================================================");
        writeln("Usage: seowebchecker <url> [options]");
        writeln("");
        defaultGetoptPrinter("Available Options:", helpInfo.options);
        return args.length < 2 && !helpInfo.helpWanted ? 1 : 0;
    }

    string targetUrl = args[1].strip();
    auto auditor = new SeoAuditor(alertThreshold: threshold);

    auto res = auditor.audit(targetUrl);

    if (checkScoreOnly) {
        writeln("SEO Health Score: ", res.score, " / 100 (", res.grade, ") - Status: ", res.status);
        return res.status == "PASS" ? 0 : 1;
    }

    if (formatJson) {
        writeln(res.toJSON());
    } else if (formatMd) {
        writeln(res.toMarkdown());
    } else {
        writeln("==================================================");
        writeln("  SEOWebChecker — Technical SEO Audit Report");
        writeln("  Official Site: https://seowebchecker.com/");
        writeln("==================================================");
        writeln("Target URL  : ", res.url);
        writeln("Health Score: ", res.score, " / 100 (", res.grade, ") - Status: ", res.status);
        writeln("Title Tag   : ", res.title.length > 0 ? res.title : "[Missing]", " (", res.titleLength, " chars)");
        writeln("Meta Desc   : ", res.metaDescription.length > 0 ? res.metaDescription : "[Missing]", " (", res.metaDescriptionLength, " chars)");
        writeln("Viewport    : ", res.hasViewport ? "Configured" : "Missing");
        writeln("Canonical   : ", res.hasCanonical ? res.canonicalUrl : "Missing");
        writeln("HTTPS       : ", res.isHttps ? "Secure" : "Insecure");
        writeln("Word Count  : ", res.wordCount, " words");
        writefln("Response    : %.2f ms", res.responseTimeMs);
        writeln("--------------------------------------------------");
        writeln("Passed      : ", res.passes.length, " checks");
        writeln("Issues      : ", res.issues.length, " items");

        if (res.issues.length > 0) {
            writeln("\nTop Issues to Fix:");
            foreach (ref const i; res.issues) {
                string tag = i.severity == "error" ? "[ERROR]" : "[WARN] ";
                writeln("  ", tag, " ", i.title, ": ", i.message);
                writeln("         Fix: ", i.recommendation);
            }
        }
        writeln("==================================================");
    }

    return res.status == "PASS" ? 0 : 1;
}
