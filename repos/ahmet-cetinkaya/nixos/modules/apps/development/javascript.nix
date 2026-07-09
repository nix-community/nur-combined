{
  pkgs,
  lib,
  ...
}: let
  bunPackages = {
    "@anthropic-ai/claude-code" = "claude";
    "@anthropic-ai/sandbox-runtime" = "sandbox-runtime";
    "@google/gemini-cli" = "gemini";
    "@kilocode/cli" = "kilo";
    "@openai/codex" = "codex";
    "@qwen-code/qwen-code" = "qwen";
    "add-gitignore" = "add-gitignore";
    "fallow" = "fallow";
    "opencode-ai" = "opencode";
  };
in {
  environment.systemPackages = with pkgs; [
    nodejs
    bun
    prettier
  ];

  home-manager.sharedModules = [
    {
      home.sessionPath = ["$HOME/.bun/bin"];
      home.activation.bunGlobalPackages = lib.mkAfter ''
        export PATH="/run/current-system/sw/bin:$PATH"

        if ! command -v bun >/dev/null 2>&1; then
          echo "bun not found, skipping bun global packages installation."
          exit 0
        fi

        ensure_bun_package_latest() {
          local package="$1"
          local binary="$2"

          if [ -x "$HOME/.bun/bin/$binary" ]; then
            echo "Updating bun global package: $package..."
            if ! bun update -g "$package"; then
              echo "Failed to update bun global package: $package" >&2
            fi
            return
          fi

          echo "Installing bun global package: $package..."
          if ! bun install -g "$package"; then
            echo "Failed to install bun global package: $package" >&2
          fi
        }

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        package: binary: "    ensure_bun_package_latest \"${package}\" \"${binary}\""
      )
      bunPackages
    )}
      '';
    }
  ];
}
