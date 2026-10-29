package com.seowebchecker;

/**
 * Represents an individual SEO check finding or issue.
 */
public class Issue {
    private final String id;
    private final String category;
    private final String severity; // pass, warning, error, notice
    private final String title;
    private final String message;
    private final String recommendation;

    public Issue(String id, String category, String severity, String title, String message, String recommendation) {
        this.id = id;
        this.category = category;
        this.severity = severity;
        this.title = title;
        this.message = message;
        this.recommendation = recommendation;
    }

    public String getId() { return id; }
    public String getCategory() { return category; }
    public String getSeverity() { return severity; }
    public String getTitle() { return title; }
    public String getMessage() { return message; }
    public String getRecommendation() { return recommendation; }

    @Override
    public String toString() {
        return "[" + severity.toUpperCase() + "] " + title + ": " + message;
    }
}
