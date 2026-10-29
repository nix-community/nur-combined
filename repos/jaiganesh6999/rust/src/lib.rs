//! SEOWebChecker SEO Audit SDK for Rust
//! Official Website: https://seowebchecker.com/

use regex::Regex;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Issue {
    pub id: String,
    pub category: String,
    pub severity: String,
    pub title: String,
    pub message: String,
    pub recommendation: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SeoScore {
    pub overall: u32,
    pub grade: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AuditResult {
    pub url: String,
    pub score: SeoScore,
    pub total_checks: usize,
    pub passed_checks: usize,
    pub warnings: usize,
    pub errors: usize,
    pub issues: Vec<Issue>,
    pub metadata: HashMap<String, String>,
}

pub struct SEOAuditor {
    pub user_agent: String,
}

impl Default for SEOAuditor {
    fn default() -> Self {
        Self {
            user_agent: "SEOWebChecker-RustBot/1.0 (+https://seowebchecker.com/)".to_string(),
        }
    }
}

impl SEOAuditor {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn audit_html(&self, html: &str, url: &str) -> AuditResult {
        let mut issues = Vec::new();
        let mut metadata = HashMap::new();

        // 1. Title
        let title_re = Regex::new(r"(?is)<title[^>]*>(.*?)</title>").unwrap();
        let title = title_re.captures(html).map(|c| c[1].trim().to_string());

        if let Some(ref t) = title {
            metadata.insert("title".to_string(), t.clone());
            let len = t.chars().count();
            if len < 30 {
                issues.push(Issue {
                    id: "meta-title-short".into(),
                    category: "meta".into(),
                    severity: "warning".into(),
                    title: "Title Too Short".into(),
                    message: format!("Title has {} characters.", len),
                    recommendation: "Expand title to 30-60 characters.".into(),
                });
            } else if len > 65 {
                issues.push(Issue {
                    id: "meta-title-long".into(),
                    category: "meta".into(),
                    severity: "warning".into(),
                    title: "Title Too Long".into(),
                    message: format!("Title has {} characters.", len),
                    recommendation: "Trim title under 60 characters.".into(),
                });
            } else {
                issues.push(Issue {
                    id: "meta-title-pass".into(),
                    category: "meta".into(),
                    severity: "pass".into(),
                    title: "Optimal Title Length".into(),
                    message: format!("Title length is {} characters.", len),
                    recommendation: "Maintain concise title.".into(),
                });
            }
        } else {
            issues.push(Issue {
                id: "meta-title-missing".into(),
                category: "meta".into(),
                severity: "error".into(),
                title: "Missing Title Tag".into(),
                message: "No <title> tag found.".into(),
                recommendation: "Add descriptive <title> tag.".into(),
            });
        }

        // 2. Viewport
        let vp_re = Regex::new(r#"(?i)<meta[^>]*name=["']viewport["']"#).unwrap();
        if vp_re.is_match(html) {
            issues.push(Issue {
                id: "meta-viewport-pass".into(),
                category: "meta".into(),
                severity: "pass".into(),
                title: "Mobile Viewport Present".into(),
                message: "Mobile viewport meta tag configured.".into(),
                recommendation: "Mobile responsive.".into(),
            });
        } else {
            issues.push(Issue {
                id: "meta-viewport-missing".into(),
                category: "meta".into(),
                severity: "error".into(),
                title: "Missing Viewport".into(),
                message: "No viewport tag detected.".into(),
                recommendation: "Add viewport meta tag.".into(),
            });
        }

        // 3. Headings
        let h1_re = Regex::new(r"(?is)<h1[^>]*>(.*?)</h1>").unwrap();
        let h1_count = h1_re.find_iter(html).count();
        if h1_count == 0 {
            issues.push(Issue {
                id: "content-h1-missing".into(),
                category: "content".into(),
                severity: "error".into(),
                title: "Missing <h1> Tag".into(),
                message: "No <h1> heading found.".into(),
                recommendation: "Add a single <h1> heading.".into(),
            });
        } else if h1_count == 1 {
            issues.push(Issue {
                id: "content-h1-pass".into(),
                category: "content".into(),
                severity: "pass".into(),
                title: "Single <h1> Tag Configured".into(),
                message: "Found exactly 1 primary <h1> heading.".into(),
                recommendation: "Good heading hierarchy.".into(),
            });
        } else {
            issues.push(Issue {
                id: "content-h1-multiple".into(),
                category: "content".into(),
                severity: "warning".into(),
                title: format!("Multiple <h1> Tags ({})", h1_count),
                message: format!("Found {} <h1> tags.", h1_count),
                recommendation: "Consolidate down to a single <h1>.".into(),
            });
        }

        // 4. HTTPS
        let is_https = url.to_lowercase().starts_with("https://");
        if is_https {
            issues.push(Issue {
                id: "tech-https-pass".into(),
                category: "technical".into(),
                severity: "pass".into(),
                title: "Secure HTTPS Active".into(),
                message: "Secured over HTTPS.".into(),
                recommendation: "Keep SSL certificate valid.".into(),
            });
        } else {
            issues.push(Issue {
                id: "tech-not-https".into(),
                category: "technical".into(),
                severity: "error".into(),
                title: "Insecure HTTP Protocol".into(),
                message: "URL does not use HTTPS.".into(),
                recommendation: "Install SSL certificate.".into(),
            });
        }

        let passed = issues.iter().filter(|i| i.severity == "pass").count();
        let warnings = issues.iter().filter(|i| i.severity == "warning").count();
        let errors = issues.iter().filter(|i| i.severity == "error").count();

        let total = issues.len();
        let mut score: i32 = if total > 0 {
            ((passed as f64 / total as f64) * 100.0).round() as i32
        } else {
            80
        };
        score -= (errors as i32 * 10) + (warnings as i32 * 3);
        let final_score = score.clamp(0, 100) as u32;

        let grade = match final_score {
            95..=100 => "A+",
            90..=94 => "A",
            80..=89 => "B",
            70..=79 => "C",
            60..=69 => "D",
            _ => "F",
        }
        .to_string();

        AuditResult {
            url: url.to_string(),
            score: SeoScore {
                overall: final_score,
                grade,
            },
            total_checks: total,
            passed_checks: passed,
            warnings,
            errors,
            issues,
            metadata,
        }
    }
}
