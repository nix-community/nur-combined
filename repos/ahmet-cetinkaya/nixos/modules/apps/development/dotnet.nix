{
  pkgs,
  lib,
  ...
}: let
  dotnetTools = [
    "csharpier"
  ];
in {
  environment.systemPackages = with pkgs; [
    (dotnetCorePackages.combinePackages [
      dotnetCorePackages.sdk_8_0-bin
      dotnetCorePackages.sdk_9_0-bin
      dotnetCorePackages.sdk_10_0-bin
      dotnetCorePackages.sdk_11_0-bin
    ])
  ];

  home-manager.users.ac.home.activation.dotnetGlobalTools = lib.mkAfter ''
        export PATH="/run/current-system/sw/bin:$PATH"

        if ! command -v dotnet >/dev/null 2>&1; then
          echo "dotnet not found, skipping dotnet global tools installation."
          exit 0
        fi

        ensure_dotnet_tool_latest() {
          local tool_name="$1"

          if dotnet tool list -g | awk '{print $1}' | grep -qx "$tool_name"; then
            echo "Updating dotnet tool: $tool_name..."
            if ! dotnet tool update -g "$tool_name"; then
              echo "dotnet tool update failed: $tool_name" >&2
            fi
            return
          fi

          echo "Installing dotnet tool: $tool_name..."
          if ! dotnet tool install -g "$tool_name"; then
            echo "dotnet tool installation failed: $tool_name" >&2
          fi
        }

    ${lib.concatMapStringsSep "\n" (
        tool_name: "    ensure_dotnet_tool_latest \"${tool_name}\""
      )
      dotnetTools}
  '';
}
