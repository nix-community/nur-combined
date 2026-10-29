<?php

declare(strict_types=1);

namespace SeoWebChecker\SeoAudit;

/**
 * Encapsulates the SEO audit result payload and formatting methods.
 */
class AuditResult
{
    public function __construct(
        public readonly string $url,
        public readonly string $timestamp,
        public readonly int $score,
        public readonly string $grade,
        public readonly array $categories,
        public readonly array $stats,
        public readonly array $meta,
        public readonly array $content,
        public readonly array $images,
        public readonly array $technical,
        public readonly array $performance,
        public readonly array $issues,
        public readonly array $errors,
        public readonly array $warnings,
        public readonly array $passed
    ) {
    }

    public function toArray(): array
    {
        return [
            'url' => $this->url,
            'timestamp' => $this->timestamp,
            'score' => [
                'overall' => $this->score,
                'grade' => $this->grade,
                'categories' => $this->categories,
            ],
            'stats' => $this->stats,
            'meta' => $this->meta,
            'content' => $this->content,
            'images' => $this->images,
            'technical' => $this->technical,
            'performance' => $this->performance,
            'issues' => $this->issues,
        ];
    }

    public function toJson(int $flags = JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES): string
    {
        return json_encode($this->toArray(), $flags);
    }

    public function toMarkdown(): string
    {
        $md = "# SEO Audit Report: {$this->url}\n\n";
        $md .= "> Audited with [SEOWebChecker](https://seowebchecker.com/) on `{$this->timestamp}`\n\n";
        $md .= "## Executive Summary\n";
        $md .= "- **Overall Score:** **`{$this->score}/100`** (Grade: **{$this->grade}**)\n";
        $md .= "- **Passed Checks:** `{$this->stats['passed']}`\n";
        $md .= "- **Warnings:** `{$this->stats['warnings']}`\n";
        $md .= "- **Errors:** `{$this->stats['errors']}`\n\n";

        $md .= "### Category Scores\n";
        $md .= "| Category | Score | Passed | Warnings | Errors |\n";
        $md .= "| :--- | :---: | :---: | :---: | :---: |\n";
        foreach ($this->categories as $name => $cat) {
            $md .= "| " . ucfirst($name) . " | **{$cat['score']}/100** | {$cat['passed_count']} | {$cat['warning_count']} | {$cat['error_count']} |\n";
        }
        $md .= "\n";

        if (!empty($this->errors)) {
            $md .= "## High Priority Issues (Errors)\n";
            foreach ($this->errors as $err) {
                $md .= "### ❌ {$err['title']}\n";
                $md .= "- **Category:** `{$err['category']}`\n";
                $md .= "- **Issue:** {$err['message']}\n";
                $md .= "- **Fix:** {$err['recommendation']}\n\n";
            }
        }

        $md .= "---\n*Automate SEO audits with [seowebchecker/seoaudit-sdk](https://seowebchecker.com/).*";
        return $md;
    }
}
