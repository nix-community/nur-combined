# docs: <https://pi.dev/docs/latest>
# docs: `pi --help`
#
## nix operation
# - config: <repo:nix-community/home-manager:modules/programs/pi-coding-agent.nix>
# - extensions: <repo:nur-combined:repos/wenjinnn/pkgs/pi-packages>
#
## extensions
# - <https://pi.dev/packages>
# - see `nix operation` above for building/shipping in nix
#
## built-in tools
# from `pi --help`, built-in tools:
# - read   - Read file contents
# - bash   - Execute bash commands
# - edit   - Edit files with find/replace
# - write  - Write files (creates/overwrites)
# - grep   - Search file contents (read-only, off by default)
# - find   - Find files by glob pattern (read-only, off by default)
# - ls     - List directory contents (read-only, off by default)

{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.pi-coding-agent.config;
  deskoHostname = config.sane.hosts.by-name.desko.wg-home.ip;
  llamaCppModels = pkgs.llama-cpp-models.models;
  llamaCppModelList = builtins.attrValues llamaCppModels;
  llamaCppModelsJson = (pkgs.formats.json {}).generate "llama-cpp-models.json" {
    providers.llama-cpp = {
      baseUrl = "http://${deskoHostname}:11435";
      api = "openai-completions";
      apiKey = "none";
      models = lib.map (p: { id = p.id; name = p.id; }) llamaCppModelList;
    };
  };

  pollinationsModelsJson = (pkgs.formats.json {}).generate "pollination-models.json" {
    providers.poll = {
      baseUrl = "https://text.pollinations.ai/v1";
      api = "openai-completions";
      apiKey = "none";
      models = [
        {
          id = "gpt-oss-20b";
          name = "gpt-oss-20b";
          cost.input = 0;
          cost.output = 0;
          cost.cacheRead = 0;
          cost.cacheWrite = 0;
          # guesses, from nanogpt's oss-20b
          contextWindow = 128000;
          maxTokens = 16384;
          reasoning = true;
          input = [
            "text"
          ];
        }
      ];
    };
  };

  # MCP config consumed by pi-mcp-adapter
  # config docs: <https://github.com/nicobailon/pi-mcp-adapter#config>
  mcpConfig = (pkgs.formats.json {}).generate "pi-mcp.json" {
    mcpServers = {
      # agent-lsp = {
      #   command = "agent-lsp";
      #   args = [
      #    "nix:nixd"
      #    "rust:rust-analyzer"
      #    "python:pyright-langserver,--stdio"
      #    "typescript:typescript-language-server,--stdio"
      #    "javascript:typescript-language-server,--stdio"
      #    "lua:lua-language-server"
      #   ];
      #   # directTools = true;
      # };
      # ccc = {
      #   command = "ccc";
      #   args = [ "mcp" ];
      #   # just a single `search` tool.
      #   directTools = true;
      # };
      # ck = {
      #   command = "ck";
      #   args = [ "--serve" ];
      #   directTools = [
      #     "hybrid_search"
      #     "lexical_search"
      #     "semantic_search"
      #     "regex_search"
      #   ];
      # };
      coderag = lib.optionalAttrs cfg.coderag {
        command = "coderag";
        args = [ "mcp" ];
        directTools = [
          "search_code"
          "search_files"
          # "get_file"
        ];
      };
      # fetch = {
      #   # seemingly no command to fetch w/o applying any transformation
      #   command = "mcp-fetch-server";
      #   # directTools = true;
      #   directTools = [
      #     "fetch_html"
      #     "fetch_markdown"
      #     # "fetch_txt"
      #     # "fetch_json"  # parses the result as json and then stringifies it as json
      #     "fetch_readable"  # like Firefox's reader mode
      #     "fetch_youtube_transcript"
      #   ];
      # };
      # fetch = {
      #   command = "mcp-server-fetch";
      #   directTools = true;
      #   # lifecycle = "eager";
      # };
      fetch = {
        command = "sane-fetch";
        args = [ "mcp" ];
        directTools = true;
      };
      home_assistant = {
        command = "ha-mcp";
        directTools = false;
      };
      # XXX(2026-06-18): kagimcp requires emailing kagi support to be whitelisted
      # kagi = {
      #   command = "kagimcp";
      # };
      # markitdown = {
      #   # provides one "markitdown_convert_to_markdown" tool.
      #   # 67 tokens.. LLMs reach for it naturally, but takes 1-2 seconds to initialize.
      #   command = "markitdown-mcp";
      #   directTools = true;
      # };
      # mcpls = {
      #   command = "mcpls";
      #   directTools = true;
      # };
      playwright = {
        command = "playwright-mcp";
        args = [
          # from <repo:NixOS/nixpkgs:pkgs/by-name/pl/playwright-mcp/package.nix>
          "--headless"
          "--isolated"
          "--output-dir"  "/tmp"
        ];
        directTools = [
          # models don't know to load the playwright MCP unless aggressively prompted;
          # after loading the MCP, they gravitate toward this sequence:
          # 1. browser_navigate  to some page
          # 2. browser_evaluate  to extract the desired content
          "browser_navigate"
          "browser_evaluate"
        ];
      };
      search = {
        command = "kagi";
        args = [ "mcp" ];
        directTools = [
          # "kagi_ask_page"
          "kagi_batch_search"
          # "kagi_fastgpt"  #< "this command requires KAGI_API_TOKEN"
          "kagi_quick" # Get a Kagi Quick Answer
          "kagi_search" # Search Kagi
          "kagi_translate"
          # "kagi_news" # Fetch Kagi News stories for a category
          "kagi_news_search" # Search the News tab of kagi.com
        ];
        excludeTools = [
          "kagi_extract" # Extract a page's full content as markdown (requires KAGI_API_KEY)
          "kagi_summarize" # Summarize a URL or text (requires KAGI_API_KEY)
        ];
      };
      # serena = {
      #   # memory system, code search, but in practice not that helpful
      #   command = "serena";
      #   args = [ "start-mcp-server" ];
      # };
    };
  };
in
{
  sane.programs.pi-coding-agent = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
          coderag = mkOption {
            type = types.bool;
            default = true;
          };
        };
      };
    };

    buildCost = 1;

    packageUnwrapped = pkgs.pi-coding-agent.overrideAttrs (prevAttrs: {
      nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ [
        pkgs.makeWrapper
      ];
      # upstream package wraps the program to add rg to PATH;
      # hijack that to also add the api key.
      #
      # env vars:
      # - PI_CODING_AGENT_DIR: Override config directory (default: ~/.pi/agent)
      # - PI_CODING_AGENT_SESSION_DIR: Override session storage directory (overridden by --session-dir)
      # - PI_PACKAGE_DIR: Override package directory
      # - PI_OFFLINE: Disable startup network operations (update checks, package update checks, telemetry)
      # - PI_SKIP_VERSION_CHECK: Skip the Pi version update check at startup
      # - PI_TELEMETRY: Override install/update telemetry (1/true/yes to enable, 0/false/no to disable)
      # - PI_CACHE_RETENTION: Set to long for extended prompt cache (Anthropic: 1h, OpenAI: 24h)
      postFixup = ''
        wrapProgram() {
          wrapProgramShell "$@" \
            --set-default PI_OFFLINE 1 \
            --set-default PI_SKIP_VERSION_CHECK 1 \
            --run 'export PI_CODING_AGENT_DIR=''${PI_CODING_AGENT_DIR:-$XDG_CONFIG_HOME/pi}' \
            --run 'export NANOGPT_API_KEY=''${NANOGPT_API_KEY:-$(cat "$XDG_CONFIG_HOME/nanogpt/nanogpt_api_key")}'
        }
        ${prevAttrs.postFixup}
      '';
    });

    suggestedPrograms = [
      # "agent-lsp"
      # "ck"
      # "cocoindex-code"
      # "fetch-mcp"
      "ha-mcp"
      "kagi-cli"
      # "kagi-ken-cli"  # for pi-kagi
      # "kagimcp"
      # "markitdown-mcp"
      # "mcpls"
      # "mcp-server-fetch"
      "nanogpt-api"
      # "nanogpt-mcp"
      "nix-prefetch-git"  # agents make use of this
      # "pandoc"  # for pi-markdown-preview
      # "pi-lens"
      "playwright-mcp"
      "sane-fetch"
      # "serena"
    ] ++ lib.optionals cfg.coderag [
      "coderag"
    ];

    sandbox.net = "clearnet";
    sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      # ".cache/ck"
      ".cache/coderag"
      # ".cocoindex_code"
      ".config/ha-mcp/ha-mcp.env"
      # ".config/kagi/kagi-api-key"
      # ".config/kagi/kagi_session_token"
      ".config/kagi-cli/config.toml"
      # ".config/mcpls"
      ".config/nanogpt/nanogpt_api_key"
      ".config/pi"
      # ".pi-lens"
      # ".pi"  #< default for if my `PI_CODING_AGENT_DIR` override doesn't take everywhere
      # for convenience
      "dev"
      "ref"
    ];
    sandbox.extraPaths = [
      "/nix/var/nix/daemon-socket"
    ];

    # sandbox.whitelistWayland = true;  # for pi-md-export -> wl-copy
    # sandbox.keepPidsAndProc = true;  #< likely required for wl-copy to work

    persist.byStore.private = [
      ".config/pi/sessions"
      ".config/pi/trust"
    ];
    fs.".config/pi/trust.json".symlink.target = "trust/trust.json";

    fs.".config/pi/mcp.json".symlink.target = mcpConfig;

    fs.".config/pi/models.json".symlink.target = pkgs.runCommand "pi-models.json" {
      nativeBuildInputs = [ pkgs.jq ];
    } ''
      jq --slurp '.[0] * .[1] * .[2]' \
        ${pkgs.nanogpt-data}/share/pi/models-nanogpt.json \
        ${llamaCppModelsJson} \
        ${pollinationsModelsJson} \
        > $out
    '';
    fs.".config/pi/settings.json".symlink.target = (pkgs.formats.json {}).generate "pi-settings.json" {
      # defaultModel = "google/gemma-4-31b-it";
      # defaultProvider = "nano-gpt";
      # defaultModel = llamaCppModels.gemma-4-26b-a4b-it-qat-ud-q4_k_xl.id;
      # defaultModel = llamaCppModels.qwen3_5-122b-a10b-ud-q4_k_xl.id;
      # defaultModel = llamaCppModels.qwen3_5-122b-a10b-ud-iq4_xs.id;
      defaultModel = llamaCppModels.qwen-agentworld-35b-a3b-ud-iq3_s.id;
      defaultProvider = "llama-cpp";
      defaultThinkingLevel = "medium";
      enableInstallTelemetry = false;
      terminal.showTerminalProgress = true;
      theme = "light";
      packages = [
        # pkgs.pi-caveman  #< adds `/caveman` slash command
        pkgs.edb-context-viewer  #< adds `/context` slash command
        pkgs.edb-diff-files  #< adds `/diff-files` slash command
        pkgs.pi-codex-goal
        pkgs.pi-cwd
        # pkgs.pi-goal  #< adds `/goal` slash command
        # pkgs.pi-kagi  #< adds `web_search` tool
        # pkgs.pi-lens  #< adds LSP support, but also a lot of tool noise
        pkgs.pi-mcp-adapter  #< adds MCP (Model Context Protocol) support
        # pkgs.pi-md-export  #< adds `/md` slash command
        # pkgs.pi-move-session  #< adds `/move-session` slash command
        pkgs.pi-speeed
        # pkgs.pi-subagents
        pkgs.pi-tool-repair  #< repairs "Error: Upstream emitted malformed tool call data that could not be repaired"
        # pkgs.pi-simplify  #< adds `/simplify` slash command
        pkgs.pi-vim  #< makes the input textarea behave like vim
        # pkgs.pi-markdown-preview  #< renders $LaTeX$, etc, but needs more deps (puppeteer?)
      ];
      enabledModels = lib.mapAttrsToList (_: m: m.id) llamaCppModels ++
        [
        # default set for Ctrl+P cycling
        # # "llama-cpp/${llamaCppModels.gemma-4-12b-it-qat-ud-q4_k_xl.id}"
        # # "llama-cpp/${llamaCppModels.gemma-4-e4b-it-qat-ud-q4_k_xl.id}"
        # "llama-cpp/${llamaCppModels.gemma-4-26b-a4b-it-qat-ud-q4_k_xl.id}"
        # "llama-cpp/${llamaCppModels.gemma-4-31b-it-qat-ud-q4_k_xl.id}"
        # "llama-cpp/${llamaCppModels.qwen-agentworld-35b-a3b-ud-iq2_m.id}"
        # "llama-cpp/${llamaCppModels.qwen-agentworld-35b-a3b-ud-iq3_s.id}"
        # "llama-cpp/${llamaCppModels.qwen-agentworld-35b-a3b-iq4_nl.id}"
        # "llama-cpp/${llamaCppModels.qwen3_6-35b-a3b-mtp-ud-q4_k_m.id}"
        # "llama-cpp/${llamaCppModels.qwen3_6-27b-mtp-q4_k_m.id}"
        # "llama-cpp/${llamaCppModels.qwen3_5-9b-q4_k_m.id}"
        # "llama-cpp/${llamaCppModels.qwen3_5-122b-a10b-ud-iq4_xs.id}"
        # # "llama-cpp/${llamaCppModels.qwen3_5-122b-a10b-ud-q4_k_xl.id}"
        # "llama-cpp/${llamaCppModels.step3_7-flash-iq4_xs.id}"
        "poll/gpt-oss-20b"
        "qwen3.5-122b-a10b"
        "google/gemma-4-31b-it"
        "moonshotai/kimi-latest"
        "deepseek/deepseek-latest"
        "zai-org/glm-latest"
        # "x-ai/grok-latest"
        "openai/gpt-5.5"
        "openai/gpt-chat-latest"
        "google/gemini-pro-latest"
        "anthropic/claude-opus-latest"
        # "mercury-2"
        # "google/gemini-flash-latest"
        # "moonshotai/kimi-latest"
        # "openai/gpt-oss-120b"
        # "auto-model-basic" 
      ];
      treeFilterMode = "user-only";
      branchSummary.skipPrompt = true;
    };

    # SYSTEM.md or APPEND_SYSTEM.md for prompt customization.
    # see: packages/coding-agent/src/core/system-prompt.ts
    #
    # populating SYSTEM.md causes this prompt:
    # ```md
    # {SYSTEM.md}
    #
    # {APPEND_SYSTEM.md}
    #
    # # Project Context
    #
    # Project-specific instructions and guidelines:
    #
    # %{foreach(filePath,content)}
    # ## {filePath}
    #
    # {content}
    # %{endforeach}
    #
    # The following skills provide specialized instructions for specific tasks.
    # Use the read tool to load a skill's file when the task matches its description.
    # When a skill file references a relative path, resolve it against the skill directory (parent of SKILL.md / dirname of the path) and use that absolute path in tool commands.
    #
    # <available_skills>
    #   <skill>
    #     <name>{skill.name}</name>
    #     <description>{skill.description}</description>
    #     <location>{skill.location}</location>
    #   </skill>
    # </available_skills>
    #
    # Current date: {date}
    # Current working directory: {promptCwd}
    # ```
    #
    # Otherwise, the default prompt is something like:
    # ```
    # You are an expert coding assistant operating inside pi, a coding agent harness. You help users by reading files, executing commands, editing code, and writing new files.
    #
    # Available tools:
    # {toolsList}
    #
    # In addition to the tools above, you may have access to other custom tools depending on the project.
    #
    # Guidelines:
    # {guidelines}
    #
    # Pi documentation (read only when the user asks about pi itself, its SDK, extensions, themes, skills, or TUI):
    # - Main documentation: {readmePath}
    # - Additional docs: {docsPath}
    # - Examples: {examplesPath} (extensions, custom tools, SDK)
    # - When asked about: extensions (docs/extensions.md, examples/extensions/), themes (docs/themes.md), skills (docs/skills.md), prompt templates (docs/prompt-templates.md), TUI components (docs/tui.md), keybindings (docs/keybindings.md), SDK integrations (docs/sdk.md), custom providers (docs/custom-provider.md), adding models (docs/models.md), pi packages (docs/packages.md)
    # - When working on pi topics, read the docs and examples, and follow .md cross-references before implementing
    # - Always read pi .md files completely and follow links to related docs (e.g., tui.md for TUI API details)`;
    #
    # {appendSection}
    #
    # {skills}
    # {date and cwd}
    # ```
    #
    # default `{toolsList}`:
    # ```
    # - read: Read file contents
    # - bash: Execute bash commands
    # - edit: Make surgical edits
    # - write: Create or overwrite files
    # ```
    #
    # default `{guidelines}`:
    # ```
    # - Use bash for file operations like ls, rg, find
    # - Be concise in your responses
    # - Show file paths clearly when working with files
    # ```
    # if grep/find/ls tools are enabled, then the first guideline is instead `Prefer grep/find/ls tools over bash for file exploration (faster, respects .gitignore)`
    fs.".config/pi/SYSTEM.md".symlink.text = ''
      You are an expert coding assistant operating inside pi, a coding agent harness, within a NixOS system. You help users by reading files, executing commands, editing code, and writing new files.

      Guidelines:
      - If invoked from a git worktree, do all edits inside that tree -- do not edit adjacent or parent checkouts
      - Prefer minimal changes
      - Before making a change, search the codebase for similar files to reference, and follow existing conventions
      - When working with 3rd-party repositories check a project's pull requests and issue tracker before making code-level changes
      - Always verify your work by building relevant targets, invoking tests, or executing the actual code in a non-destructive manner (e.g. dry-run)
      - Be concise in your responses and comments
      - Do NOT modify system or user config files without explicit consent (no `git config set`, etc)
      - Do NOT remove files from the nix store without explicit consent (no `nix-collect-garbage`, `nix-store --delete`, etc)
      - Specify explicit timeouts for any recursive filesystem operations (`grep -r`, `find`, etc)

      Things to know about this environment:
      - ~/ref/repos contains several hundred git checkouts organized by $owner/$repo: consult these first when looking for third-party sources. When cloning public repos, place them in this directory rather than a temporary directory, and follow existing name conventions. Always perform full clones -- disk space is cheap.
      - This is a git-focused environment. Projects or instructions may reference mercurial: fall back to `git` (cinnabar) operations at the earliest sign that `hg` is inoperational.
      - Although a nix-based environment, `NIX_PATH` might not be set. This is intentional: invoke nix commands (`nix-build`, `nix-env`, etc) exactly as the user has specified.
    '';

    # for consideration:
    # - If the necessary tool for the job isn't listed above, use `echo $PATH | xargs -d ':' ls` to check for a suitable alternative
    # - Use `nix-build ~/dev/3rd/nixpkgs -A PACKAGE` to access binaries for any other package
    # - Also consider `nix-build ~/dev/3rd/nixpkgs -A PACKAGE.src` to access sources
    # - Show file paths clearly when working with files
    # - N.B.: Future instructions may make reference to hg (mercurial), but the remote may be hg even as the checkout is git (via e.g. git-cinnabar): use whichever frontend matches the local checkout.
    # - Use `nanogpt-api search` (from bash) for web searches
    # - Prefer rg over grep as it honors files such as .gitignore
    # - Use `kagi-ken-cli search` (from bash) for web searches
    # - `kagi-ken-cli "my search phrase"` -> search the web (json response)
    # - Use bash for operations like ls, rg, find, curl
    # - You drive requested tasks to completion without stopping for guidance except when truly stuck.
    # - ~/ref/repos and /nix/store contain MILLIONS of files: do NOT perform `grep -r` operations over these directories; explicitly limit the duration of any `find` operations.
    #
    # Available tools:
    # - read: Read file contents
    # - bash: Execute bash commands
    # - edit: Make surgical edits
    # - write: Create or overwrite files

    # Programs available through bash:
    # - `curl`
    # - `rg` -> use instead of grep; it honors .gitignore
    # - everything else you'd expect in a typical dev environment
  };
}
