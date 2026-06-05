### docs:
# - config: <https://charm.land/crush.json>
# - config: <https://github.com/charmbracelet/crush/blob/main/internal/config/config.go>
#
### MCP Servers
# - <https://github.com/modelcontextprotocol>
# in nixpkgs: `fd mcp-`
# - aks-mcp-server
# - gitea-mcp-server
# - github-mcp-server
#  - <https://github.com/github/github-mcp-server>
#  - requires creds
#  - huuuuuge range of tools, can select to expose only some of them
#    - repo `search_repositories`
#    - repo `search_code`
#    - ...
#  - limit operations: `github-mcp-server --read-only`
# - influxdb-mcp-server
# - mcp-gateway
# - mcp-grafana
# - mcp-k8s-go
# - mcp-language-server
# - mcp-nixos
#   - <https://github.com/utensils/mcp-nixos>
#   - this makes remote calls though; doesn't query local resources
# - mcp-proxy
# - mcp-server-fetch
# - mcp-server-filesystem
# - mcp-server-git
# - mcp-server-memory
# - mcp-server-sequential-thinking
# - mcp-server-time
# - terraform-mcp-server
# - django-mcp-server
#
# recommended by opencode:
# - <https://opencode.ai/docs/mcp-servers#examples>
# - <https://github.com/upstash/context7>
#   - code documentation search
# - 
{ lib, pkgs, ... }:
{
  sane.programs.crush = {
    packageUnwrapped = pkgs.crush.overrideAttrs (prevAttrs: {
      nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ [
        pkgs.makeWrapper
      ];
      postFixup = prevAttrs.postFixup or "" + ''
        wrapProgram $out/bin/crush \
          --run 'export NANOGPT_API_KEY=''${NANOGPT_API_KEY:-$(cat "$XDG_CONFIG_HOME/nanogpt/nanogpt_api_key")}'
      '';
    });

    suggestedPrograms = [
      "github-mcp-server"
      "kagimcp"
      "nanogpt-mcp"
      "mcp-server-time"
    ];

    sandbox.net = "clearnet";
    sandbox.extraHomePaths = [
      ".config/crush"
      ".config/github-mcp-server/access_token"
      ".config/kagi/kagi-api-key"
      ".config/nanogpt/nanogpt_api_key"
      ".local/share/crush"
      # useful data to reference here:
      "ref"
    ];
    sandbox.extraPaths = [
      "/nix/var/nix/daemon-socket"  # so that `nix-build ...` can work within it
    ];
    sandbox.whitelistPwd = true;

    fs.".config/crush/crush.json".symlink.target =
    let
      baseConfig = {
        models = {
          large = {
            # model = "google/gemma-4-31b-it:thinking";
            model = "google/gemma-4-31b-it";
            provider = "nano-gpt";
          };
          small = {
            model = "openai/gpt-oss-20b";
            # model = "openai/gpt-5-nano";
            # model = "gemini-2.5-flash-lite";
            # model = "google/gemini-3.1-flash-lite-preview";
            # model = "google/gemini-flash-lite-latest";
            # model = "google/gemma-4-31b-it:thinking";
            provider = "nano-gpt";
          };
        };
        options = {
          tui = {
            compact_mode = false;  #< false = show sidebar
            # compact_mode = true;
            diff_mode = "unified";
          };
          attribution = {
            # trailer_mode = "none" should have prevented `Assisted By:` lines in `git commit`, but it doesn't.
            # likely need to use a custom system prompt to prevent that.
            trailer_mode = "none";
          };
          disable_auto_summarize = true;  # this doesn't seem to do anything?
          disable_default_providers = true;
          disable_provider_auto_update = true;
          disable_metrics = true;
          debug = true;  # not sure what this does, maybe related to ./.crush/logs/crush.log?
          # disabled_tools = [
          #   "agentic_fetch"  # seems to regularly stall
          # ];
          # disabled_skills = [ ... ]
        };
        permissions = {
          # allegedly, setting `allowed_tools = []` allows _all_ tools/bash/etc.
          # several tools appear to be allowed by default, e.g. `crush_logs`.
          allowed_tools = [
            # "agent"
            "agentic_fetch"
            # "bash"
            # "crush_info"
            # "crush_logs"
            # "download"
            # "edit"
            "fetch"
            # "list_mcp_resources"
            "ls"
            # "lsp_diagnostics"
            # "lsp_references"
            # "lsp_restart"
            "glob"
            "grep"
            "mcp_github_get_commit"
            "mcp_github_get_file_contents"
            "mcp_github_get_label"
            "mcp_github_get_latest_release"
            "mcp_github_get_release_by_tag"
            "mcp_github_get_repository_tree"
            "mcp_github_get_tag"
            "mcp_github_issue_read"
            "mcp_github_list_branches"
            "mcp_github_list_commits"
            "mcp_github_list_issue_types"
            "mcp_github_list_issues"
            "mcp_github_list_pull_requests"
            "mcp_github_list_releases"
            "mcp_github_list_tags"
            "mcp_github_pull_request_read"
            "mcp_github_search_code"
            "mcp_github_search_issues"
            "mcp_github_search_pull_requests"
            "mcp_nanogpt_nanogpt_chat"
            "mcp_nanogpt_nanogpt_get_balance"
            "mcp_nanogpt_nanogpt_image_generate"
            "mcp_nanogpt_nanogpt_list_audio_models"
            "mcp_nanogpt_nanogpt_list_image_models"
            "mcp_nanogpt_nanogpt_list_text_models"
            "mcp_nanogpt_nanogpt_list_video_models"
            "mcp_nanogpt_nanogpt_scrape_urls"
            "mcp_nanogpt_nanogpt_vision"
            "mcp_nanogpt_nanogpt_web_search"
            "mcp_nanogpt_nanogpt_youtube_transcribe"
            "mcp_time_convert_time"
            "mcp_time_get_current_time"
            # "multiedit"
            # "read_mcp_resource"
            "sourcegraph"
            # "todos"
            "view"
            # "write"
          ];
        };
        mcp = {
          nanogpt = {
            type = "stdio";
            command = "nanogpt-mcp";
            args = [];
            env = {
              NANOGPT_API_KEY = "$NANOGPT_API_KEY";
            };
          };
          github = {
            type = "stdio";
            command = "github-mcp-server";
            args = [
              "stdio"
              "--read-only"
              # "--toolsets" "repos"
              "--tools" (lib.concatStringsSep "," [
                ### gists
                # "get_gist"
                # "list_gists"
                ### git
                "get_repository_tree"
                ### issues
                "get_label"
                "issue_read"
                "list_issue_types"
                "list_issues"
                "search_issues"
                ### labels
                # "get_label"
                # "list_label"
                ### pull requests
                "list_pull_requests"
                "pull_request_read"
                "search_pull_requests"
                ### repos
                "get_commit"
                "get_file_contents"
                "get_latest_release"
                "get_release_by_tag"
                "get_tag"
                "list_branches"
                "list_commits"
                "list_releases"
                "list_tags"
                "search_code"
              ])
            ];
            env = {};
          };
          kagi = {
            type = "stdio";
            command = "kagimcp";
            args = [];
            env = {};
          };
          time = {
            # timezone conversions
            type = "stdio";
            command = "mcp-server-time";
            args = [];
            env = {};
          };
        };
        lsp = {};
      };
    in
      pkgs.stdenvNoCC.mkDerivation {
        name = "crush-config.json";
        nativeBuildInputs = [ pkgs.jq ];
        src = (pkgs.formats.json {}).generate "crush-config-base.json" baseConfig;
        buildCommand = ''
          jq '.[0] + { providers: .[1] }' --slurp \
            $src \
            ${pkgs.nanogpt-data}/share/crush/providers-nanogpt.json \
            > $out
        '';
      };
    # XXX(2026-05-05): crush *writes* ~/.local/share/crush/providers.json (with its provider auto-updating),
    # but does not seem to *read* it (at least not when the auto-updates are disabled).
    # fs.".local/share/crush/providers.json".symlink.target = ./providers.json;
  };
}
