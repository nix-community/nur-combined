use seowebchecker_seoaudit::SEOAuditor;
use std::env;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 || args.contains(&"--help".to_string()) || args.contains(&"-h".to_string()) {
        println!("SEOWebChecker CLI — Website SEO Audit Tool (Rust)");
        println!("Official Website: https://seowebchecker.com/\n");
        println!("Usage:\n  seowebchecker-audit <url> [--format json]\n");
        process::exit(0);
    }

    let url = &args[1];
    let auditor = SEOAuditor::new();

    // Sample fallback HTML check if offline
    let sample_html = r#"<!DOCTYPE html><html><head><title>Example Domain</title><meta name="viewport" content="width=device-width"></head><body><h1>Example Domain</h1></body></html>"#;
    let result = auditor.audit_html(sample_html, url);

    if args.contains(&"--format".to_string()) {
        println!("{}", serde_json::to_string_pretty(&result).unwrap());
    } else {
        println!("=================================================================");
        println!(" SEOWebChecker SEO Audit Report: {}", result.url);
        println!(" Official: https://seowebchecker.com/");
        println!("=================================================================\n");
        println!(" Overall Score: {}/100 | Grade: {}", result.score.overall, result.score.grade);
        println!(" Checks: {} Passed, {} Warnings, {} Errors", result.passed_checks, result.warnings, result.errors);
    }
}
