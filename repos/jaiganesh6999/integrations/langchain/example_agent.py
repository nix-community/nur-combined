"""Example standalone LangChain tool runner for SEOWebChecker."""

from seowebchecker_seoaudit.integrations import (
    SEOWebCheckerAuditTool,
    SEOWebCheckerScoreTool,
    SEOWebCheckerMetaTool,
    get_langchain_tools,
)

def main():
    target = "https://seowebchecker.com/"
    print(f"--- Running LangChain SEOWebChecker Tools on {target} ---\n")
    
    score_tool = SEOWebCheckerScoreTool()
    score_res = score_tool.run(target)
    print("1. Score Tool Output:")
    print(score_res)
    print("\n" + "="*50 + "\n")
    
    meta_tool = SEOWebCheckerMetaTool()
    meta_res = meta_tool.run(target)
    print("2. Meta Validation Tool Output:")
    print(meta_res)
    print("\n" + "="*50 + "\n")

    audit_tool = SEOWebCheckerAuditTool()
    audit_res = audit_tool.run(target)
    print("3. Comprehensive Audit Tool Output (truncated):")
    print(audit_res[:600] + "...\n")

if __name__ == "__main__":
    main()
