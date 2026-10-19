{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents (
    with pkgs.google-cloud-sdk.components;
    [
      gke-gcloud-auth-plugin
    ]
  );

  ai = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    amp
    pkgs.fx
    (pkgs.buildGoModule {
      pname = "lard-client";
      version = "0.2.0";
      src = inputs.lard;
      vendorHash = "sha256-8n+5kNTK1ZUzRBEli3T/l7WACvOZ2eKBTk0XuE1o7+E=";
      subPackages = [ "cmd/lard-client" ];
      meta = with lib; {
        description = "Client for lard, a memory layer for homelab LLM sessions";
        homepage = "https://lard.avyay.in";
        license = licenses.mit;
        platforms = platforms.unix;
      };
    })
  ];

  aiMap = builtins.listToAttrs (
    map (
      pkg:
      let
        raw = pkg.pname or pkg.name;
        display = lib.removeSuffix "-cli" raw;
      in
      {
        name = display;
        value = {
          bin = "${pkg}/bin/${raw}";
        };
      }
    ) ai
  );
in
{
  options.dots.devenv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the devenv dotfiles module.";
    };
    rust.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the rust toolchains.";
    };
    java.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Java";
    };
    nix.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nix development/tooling packages (nh, nix-tree, cachix, etc).";
    };
    ai.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable AI/LLM CLI tools (amp, copilot-cli, crush, opencode, etc) and the aipick launcher script.";
    };
    ai.codex.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include codex in the AI CLI tools and aipick launcher.";
    };
    security.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable security/pentesting tools (nmap, ffuf, sqlmap, dalfox).";
    };
    cloud.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable cloud provider CLI tools (google-cloud-sdk, oci-cli).";
    };
    android.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Android development tooling (gradle, kotlin, android-tools, kotlin-language-server).";
    };
    asic.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ASIC/RTL development tools (iverilog, verilator, yosys, gtkwave).";
    };
  };

  config = lib.mkIf config.dots.devenv.enable {
    programs = {
      bun = {
        enable = true;
        enableGitIntegration = true;
      };
      go.enable = true;
      try.enable = true;
      ruff = {
        enable = true;
        settings = {
          line-length = 100;
          per-file-ignores = {
            "__init__.py" = [ "F401" ];
          };
          lint = {
            select = [ ];
            ignore = [ ];
          };
        };
      };
      ty = {
        enable = true;
      };
      java = {
        enable = config.dots.devenv.java.enable;
        # FTC's Gradle tooling (and IntelliJ's bundled JBR) expect JDK 17.
        package = lib.mkIf config.dots.devenv.android.enable pkgs.jdk17;
      };
      claude-code = {
        enable = config.dots.devenv.ai.enable;
        enableMcpIntegration = true;
      };
      pi-coding-agent.enable = config.dots.devenv.ai.enable;
      github-copilot-cli = {
        enable = config.dots.devenv.ai.enable;
        enableMcpIntegration = true;
      };
      antigravity-cli = {
        enable = config.dots.devenv.ai.enable;
        enableMcpIntegration = true;
      };
      crush = {
        enable = config.dots.devenv.ai.enable;
        # package = pkgs.nur.charmbracelet.crush; FIXME charmbracelet repo not resolving in nur
        enableMcpIntegration = true;
      };
      opencode = {
        enable = config.dots.devenv.ai.enable;
        enableMcpIntegration = true;
      };
      codex = {
        enable = config.dots.devenv.ai.codex.enable;
        settings = {
          default_permissions = ":workspace";
          projects = {
            "${config.home.homeDirectory}/nix" = {
              trust_level = "trusted";
            };
            "${config.home.homeDirectory}/Code" = {
              trust_level = "trusted";
            };
          };
        };
        # enableMcpIntegration = true;
      };
      mcp = {
        enable = config.dots.devenv.ai.enable;
        servers = {
          lard = {
            type = "http";
            url = "https://lard.avyay.in/mcp";
            oauth = true;
          };
          chrome-devtools = {
            command = "${pkgs.bun}/bin/bunx";
            args = [
              "-y"
              "chrome-devtools-mcp@latest"
            ];
          };
          package-search = {
            url = "https://mcp.trychroma.com/package-search/v1";
            headers = {
              x-chroma-token = "{env:CHROMA_MCP_TOKEN}";
            };
            type = "http";
          };

        };
      };
      awscli = {
        enable = config.dots.devenv.cloud.enable;
      };
    };

    home.packages = [
      pkgs.biome
      # Go tooling: gopls is pinned in the Helix config; keep CLI linting and debugging available.
      pkgs.golangci-lint
      pkgs.delve
      pkgs.nodejs
      pkgs.nil
      pkgs.surge-cli
      pkgs.deno

      pkgs.pnpm
      pkgs.typescript
      pkgs.typescript-language-server
      pkgs.pkg-config
      pkgs.cmake
      pkgs.dbus
      pkgs.scc

      pkgs.qemu
      # pkgs.kicad
      # ruby
      pkgs.ruby
      # pkgs.bundler
      #

      pkgs.postgresql
      pkgs.ollama
      pkgs.qmk
      pkgs.xcodegen
      # pkgs.eas-cli
      pkgs.sccache
      pkgs.ccache

      pkgs.stripe-cli
      pkgs.wakatime-cli
      inputs.wakatime-ls.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.terminal-wakatime.packages.${pkgs.stdenv.hostPlatform.system}.default

      (pkgs.writeShellScriptBin "rfv" ''
        RELOAD='reload:rg --column --color=always --smart-case {q} || :'
        OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
                  $EDITOR {1} +{2}
                else
                  $EDITOR +cw -q {+f}
                fi'
        fzf --disabled --ansi --multi \
            --bind "start:$RELOAD" --bind "change:$RELOAD" \
            --bind "enter:become:$OPENER" \
            --bind "ctrl-o:execute:$OPENER" \
            --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
            --delimiter : \
            --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
            --preview-window '~4,+{2}+4/3,<80(up)' \
            --query "$*"
      '')

      (pkgs.writeShellScriptBin "hackatime-summary" ''
        # Fixed variable escaping for Nix
        user_id=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.slack_user_id.path} 2>/dev/null || echo "")
        use_waka=false

        while [[ $# -gt 0 ]]; do
          case "$1" in
            --waka) use_waka=true; shift ;;
            *) user_id="$1"; shift ;;
          esac
        done

        if [[ -z "$user_id" ]]; then
          user_id=$(${pkgs.gum}/bin/gum input --placeholder "Enter user ID" --prompt "User ID: ")
        fi

        [[ -z "$user_id" ]] && { ${pkgs.gum}/bin/gum style --foreground 196 "No user ID"; exit 1; }

        host=$([[ "$use_waka" = true ]] && echo "waka.hackclub.com" || echo "hackatime.hackclub.com")

        ${pkgs.gum}/bin/gum spin --spinner dot --title "Fetching from $host..." -- \
          ${pkgs.curl}/bin/curl -s -X 'GET' "https://$host/api/summary?user=''${user_id}&interval=month" \
          -H 'accept: application/json' \
          -H 'Authorization: Bearer 2ce9e698-8a16-46f0-b49a-ac121bcfd608' > /tmp/hackatime-$$.json

        total_seconds=$(${pkgs.jq}/bin/jq -r '(.categories + .projects | map(.total) | add) // 0' /tmp/hackatime-$$.json)

        if [[ "$total_seconds" -gt 0 ]]; then
          printf "Total: %dh %dm %ds\n" $((total_seconds/3600)) $(((total_seconds%3600)/60)) $((total_seconds%60))
        fi

        # Display lists
        ${pkgs.jq}/bin/jq -r '"\nTop Projects:", (.projects | sort_by(-.total)[0:5][] | "  \(.key): \(.total/3600|floor)h")' /tmp/hackatime-$$.json

        rm -f /tmp/hackatime-$$.json
      '')
    ]
    ++ lib.optionals config.dots.devenv.rust.enable [
      (pkgs.fenix.combine [
        (pkgs.fenix.complete.withComponents [
          "cargo"
          "clippy"
          "miri"
          "rust-src"
          "rustc"
          "rustfmt"
          "llvm-tools-preview"
        ])

        pkgs.fenix.targets.aarch64-unknown-none.latest.rust-std
        pkgs.fenix.targets.wasm32-wasip1.latest.rust-std
        pkgs.fenix.targets.wasm32-wasip2.latest.rust-std
        pkgs.fenix.targets.x86_64-unknown-linux-gnu.latest.rust-std
        pkgs.fenix.targets.aarch64-unknown-linux-gnu.latest.rust-std
        pkgs.fenix.targets.aarch64-apple-darwin.latest.rust-std
        pkgs.fenix.targets.aarch64-unknown-linux-musl.latest.rust-std
        pkgs.fenix.targets.x86_64-unknown-linux-musl.latest.rust-std
        pkgs.fenix.targets.armv7-unknown-linux-gnueabihf.latest.rust-std
      ])
    ]
    ++ lib.optionals config.dots.devenv.nix.enable [
      pkgs.nh
      pkgs.nix-bisect
      pkgs.nix-btm
      pkgs.nix-check-deps
      pkgs.manix
      pkgs.nurl
      pkgs.nix-du
      pkgs.devenv
      pkgs.angrr
      pkgs.nix-diff
      pkgs.dix
      pkgs.nix-tree
      pkgs.cachix
      pkgs.omnix
      pkgs.autoflake
      pkgs.nix-search-cli
      pkgs.sops
      pkgs.nix-fast-build
      pkgs.nix-build-uncached
      pkgs.nix-converter
      pkgs.nixos-anywhere
      pkgs.nixos-rebuild
      pkgs.statix
      (pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
      })
    ]
    ++ lib.optionals config.dots.devenv.ai.enable (
      ai
      ++ [
        (pkgs.writeShellScriptBin "aipick" ''
              set -e

          choice=$(
            printf "%s\n" ${lib.concatStringsSep " " (builtins.attrNames aiMap)} \
            | tr ' ' '\n' \
            | ${pkgs.fzf}/bin/fzf --prompt="AI > "
          )

          if [ -n "$choice" ]; then
            case "$choice" in
              ${lib.concatStringsSep "\n      " (
                map (name: "${name}) exec ${aiMap.${name}.bin} ;;") (builtins.attrNames aiMap)
              )}
            esac
          fi
        '')
      ]
    )
    ++ lib.optionals config.dots.devenv.security.enable [
      pkgs.nmap
      pkgs.ffuf
      pkgs.sqlmap
      pkgs.dalfox
    ]
    ++ lib.optionals config.dots.devenv.cloud.enable [
      gdk
      pkgs.oci-cli
    ]
    ++ lib.optionals config.dots.devenv.android.enable [
      pkgs.gradle
      pkgs.kotlin
      pkgs.kotlin-language-server
      pkgs.android-tools
      pkgs.scrcpy
    ]
    ++ lib.optionals config.dots.devenv.asic.enable [
      pkgs.iverilog
      pkgs.verilator
      pkgs.yosys
      pkgs.gtkwave
    ];

    home.shellAliases = lib.mkIf config.dots.devenv.android.enable {
      # FTC Control/Expansion/Driver Hubs default to 192.168.43.1 in AP mode.
      adb-ftc = "adb connect 192.168.43.1:5555";
      adb-wifi = "adb tcpip 5555";
      ftc-log = "adb logcat -s RobotCore:V FtcRobotController:V TeleOp:V Autonomous:V";
      ftc-build = "./gradlew build";
      ftc-deploy = "./gradlew installDebug";
      ftc-clean = "./gradlew clean";
      scrcpy-ftc = "scrcpy --tcpip=192.168.43.1:5555";
    };
    programs.zsh.initContent = ''
      export CONTEXT7_API_KEY="$(cat ${config.sops.secrets.context7_api_key.path})"
      export GH_MCP_TOKEN="$(cat ${config.sops.secrets.gh_mcp_token.path})"
      export CHROMA_MCP_TOKEN="$(cat ${config.sops.secrets.chroma_mcp_token.path})"
    '';
  };
}
