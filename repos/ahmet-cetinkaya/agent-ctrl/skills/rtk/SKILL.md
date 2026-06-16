---
name: rtk
description: Rust Token Killer - Minimize LLM token consumption by summarizing CLI outputs.
---

# SKILL.md - RTK (Rust Token Killer)

Use this skill to optimize your interactions with the shell. RTK acts as a proxy for common CLI tools, filtering out noise and summarizing outputs to save tokens and extend your context window.

## Instructions

1.  **Always use `rtk` as a proxy**: For any command that generates significant output (more than 10-20 lines), prefer runing `rtk <command>`.
    -   Example: `rtk git status`, `rtk cargo test`, `rtk npm install`.
2.  **Optimized System Commands**: Use RTK's built-in optimized versions of standard tools:
    -   `rtk ls [args]`: Token-optimized directory listing.
    -   `rtk tree [args]`: Token-optimized directory tree.
    -   `rtk read <files>`: Smart file reading with filtering levels.
    -   `rtk grep <pattern> [path]`: Optimized grep with line length limits.
    -   `rtk find [args]`: Optimized find.
3.  **Token Savings Tracking**: Use `rtk gain` to check how many tokens you have saved in the current session or project.
4.  **Discovery**: If you are unsure which commands can be optimized, run `rtk discover` to scan your recent history for opportunities.
5.  **Hooks**: RTK typically installs a `PreToolUse` hook in supported agents. If you are running in an environment where the hook is active, your `bash` commands may be automatically rewritten. If not, you must manually prefix them with `rtk`.

## Tips
- Use `rtk read --level minimal <file>` for quick overviews without reading every line.
- Use `rtk gain --graph` for a visual representation of your savings.
- If a command is being incorrectly rewritten by a hook, use `rtk proxy <command>` to bypass RTK.
