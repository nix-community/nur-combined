"""Example standalone LlamaIndex tool runner for SEOWebChecker."""

from seowebchecker_seoaudit.integrations import SEOWebCheckerToolSpec

def main():
    target = "https://seowebchecker.com/"
    print(f"--- Running LlamaIndex SEOWebChecker ToolSpec on {target} ---\n")
    
    spec = SEOWebCheckerToolSpec()
    tools = spec.to_tool_list()
    print(f"Generated {len(tools)} tools from spec:")
    for t in tools:
        print(f" - {t['name']}: {t['description'][:60]}...")
    print("\n" + "="*50 + "\n")

    print("1. Quick Score Result:")
    print(spec.quick_score(target))
    print("\n" + "="*50 + "\n")

    print("2. Check Meta Result:")
    print(spec.check_meta(target))
    print("\n" + "="*50 + "\n")

    print("3. Full Audit Result (truncated):")
    print(spec.audit(target)[:600] + "...\n")

if __name__ == "__main__":
    main()
