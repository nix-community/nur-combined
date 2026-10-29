"""Command Line Interface for SEOWebChecker SEO Audit SDK."""

import argparse
import sys
from seowebchecker_seoaudit import __version__
from seowebchecker_seoaudit.auditor import SEOAuditor
from seowebchecker_seoaudit.client import SeoWebCheckerClient, SeoWebCheckerError
from seowebchecker_seoaudit.formatters import format_console, format_markdown, format_html


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="seowebchecker-audit",
        description="Lightweight open-source SEO audit tool by SEOWebChecker (https://seowebchecker.com/)",
    )
    parser.add_argument("url", nargs="?", help="Target URL to audit (e.g. https://example.com)")
    parser.add_argument(
        "-f", "--format",
        choices=["pretty", "json", "markdown", "html"],
        default="pretty",
        help="Output report format (default: pretty)",
    )
    parser.add_argument(
        "-o", "--output",
        help="Write audit report to file (e.g., report.html, audit.json, audit.md)",
    )
    parser.add_argument(
        "--min-score",
        type=int,
        default=0,
        help="Minimum acceptable SEO score (0-100). Fails with exit code 1 if score is lower (ideal for CI/CD)",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=15,
        help="Network timeout in seconds (default: 15)",
    )
    parser.add_argument(
        "--api-key",
        help="SEOWebChecker Cloud API Key (optional; uses cloud audit engine instead of local)",
    )
    parser.add_argument(
        "--no-robots",
        action="store_true",
        help="Skip probing /robots.txt",
    )
    parser.add_argument(
        "--no-sitemap",
        action="store_true",
        help="Skip probing /sitemap.xml",
    )
    parser.add_argument(
        "--no-color",
        action="store_true",
        help="Disable ANSI colors in console output",
    )
    parser.add_argument(
        "-v", "--version",
        action="version",
        version=f"%(prog)s {__version__}",
    )

    args = parser.parse_args()

    if not args.url:
        parser.print_help()
        return 1

    target_url = args.url.strip()
    if not target_url.startswith(("http://", "https://")):
        target_url = "https://" + target_url

    # Cloud API mode vs Local Auditor mode
    if args.api_key:
        client = SeoWebCheckerClient(api_key=args.api_key, timeout=args.timeout)
        try:
            print(f"Auditing {target_url} via SEOWebChecker Cloud API...")
            data = client.audit(target_url)
            print(data)
            return 0
        except SeoWebCheckerError as e:
            print(f"SEOWebChecker API Error: {e}", file=sys.stderr)
            return 1

    # Local Standalone Auditor
    auditor = SEOAuditor(
        timeout=args.timeout,
        check_robots=not args.no_robots,
        check_sitemap=not args.no_sitemap,
    )

    try:
        result = auditor.audit(target_url)
    except Exception as e:
        print(f"Audit failed for {target_url}: {e}", file=sys.stderr)
        return 1

    # Format output
    if args.format == "json":
        output_text = result.to_json(indent=2)
    elif args.format == "markdown":
        output_text = format_markdown(result)
    elif args.format == "html":
        output_text = format_html(result)
    else:
        output_text = format_console(result, use_color=not args.no_color)

    # Save to file or stdout
    if args.output:
        try:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(output_text)
            print(f"Report successfully saved to: {args.output}")
        except Exception as e:
            print(f"Error writing to {args.output}: {e}", file=sys.stderr)
            return 1
    else:
        print(output_text)

    # CI/CD Score threshold enforcement
    if args.min_score > 0 and result.score.overall < args.min_score:
        print(
            f"\n[CI/CD ERROR] Score {result.score.overall} is below minimum requirement of {args.min_score}.",
            file=sys.stderr,
        )
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
