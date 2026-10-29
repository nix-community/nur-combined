using System;
using System.Collections.Generic;

namespace SeoWebChecker.SeoAudit
{
    public class Issue
    {
        public string Id { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Severity { get; set; } = "notice"; // pass, warning, error, notice
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string Recommendation { get; set; } = string.Empty;
    }

    public class CategoryScore
    {
        public string Name { get; set; } = string.Empty;
        public int Score { get; set; }
        public int PassedCount { get; set; }
        public int WarningCount { get; set; }
        public int ErrorCount { get; set; }
    }

    public class SeoScore
    {
        public int Overall { get; set; }
        public string Grade { get; set; } = "F";
        public Dictionary<string, CategoryScore> Categories { get; set; } = new Dictionary<string, CategoryScore>();
    }

    public class AuditResult
    {
        public string Url { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
        public SeoScore Score { get; set; } = new SeoScore();
        public Dictionary<string, int> Stats { get; set; } = new Dictionary<string, int>();
        public Dictionary<string, object?> Meta { get; set; } = new Dictionary<string, object?>();
        public Dictionary<string, object?> Content { get; set; } = new Dictionary<string, object?>();
        public Dictionary<string, object?> Images { get; set; } = new Dictionary<string, object?>();
        public Dictionary<string, object?> Technical { get; set; } = new Dictionary<string, object?>();
        public Dictionary<string, object?> Performance { get; set; } = new Dictionary<string, object?>();
        public List<Issue> Issues { get; set; } = new List<Issue>();
    }
}
