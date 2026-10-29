package com.seowebchecker;

import java.util.List;
import java.util.Map;

/**
 * Result of an SEO audit inspection.
 */
public class AuditResult {
    private final String url;
    private final int overallScore;
    private final String grade;
    private final List<Issue> issues;
    private final Map<String, Object> metadata;

    public AuditResult(String url, int overallScore, String grade, List<Issue> issues, Map<String, Object> metadata) {
        this.url = url;
        this.overallScore = overallScore;
        this.grade = grade;
        this.issues = issues;
        this.metadata = metadata;
    }

    public String getUrl() { return url; }
    public int getOverallScore() { return overallScore; }
    public String getGrade() { return grade; }
    public List<Issue> getIssues() { return issues; }
    public Map<String, Object> getMetadata() { return metadata; }

    public long getPassedCount() {
        return issues.stream().filter(i -> "pass".equalsIgnoreCase(i.getSeverity())).count();
    }

    public long getErrorCount() {
        return issues.stream().filter(i -> "error".equalsIgnoreCase(i.getSeverity())).count();
    }

    public long getWarningCount() {
        return issues.stream().filter(i -> "warning".equalsIgnoreCase(i.getSeverity())).count();
    }
}
