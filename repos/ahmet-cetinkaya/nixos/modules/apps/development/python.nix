{
  pkgs,
  lib,
  ...
}: let
  uvTools = [
    {
      name = "specify-cli";
      source = "git+https://github.com/github/spec-kit.git";
    }
  ];
in {
  environment.systemPackages = with pkgs; [
    python3
    uv
  ];

  home-manager.sharedModules = [
    {
      home.activation.uvGlobalTools = lib.mkAfter ''
        export PATH="/run/current-system/sw/bin:$PATH"

        if ! command -v uv >/dev/null 2>&1; then
          echo "uv not found, skipping uv tools installation."
          exit 0
        fi

        ensure_uv_tool_latest() {
          local tool_name="$1"
          local tool_source="$2"

          if uv tool list | awk '{print $1}' | grep -qx "$tool_name"; then
            echo "Updating uv tool: $tool_name..."
            if ! uv tool upgrade "$tool_name"; then
              echo "uv tool update failed for '$tool_name', retrying with source install..." >&2
              if ! uv tool install "$tool_name" --from "$tool_source"; then
                echo "uv tool installation failed: $tool_name" >&2
              fi
            fi
            return
          fi

          echo "Installing uv tool: $tool_name..."
          if ! uv tool install "$tool_name" --from "$tool_source"; then
            echo "uv tool installation failed: $tool_name" >&2
          fi
        }

    ${lib.concatMapStringsSep "\n" (
        tool: "    ensure_uv_tool_latest \"${tool.name}\" \"${tool.source}\""
      )
      uvTools}
      '';
    }
  ];
}
