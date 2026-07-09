{
  pkgs,
  lib,
  ...
}: let
  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0-bin;
in {
  environment.systemPackages = with pkgs; [
    # .NET
    dotnetSdk

    # JavaScript / Node
    nodejs
    bun
    pnpm

    # VPN
    openfortigui
    openfortivpn

    # CLI Tools
    git
    gh

    # Database
    mongodb-compass

    # PDF generation
    wkhtmltopdf

    # Containers (GUI only; connects to the native Docker Engine below)
    podman-desktop

    # Communication
    teams-for-linux
    slack
    thunderbird
  ];

  home-manager.sharedModules = [
    {
      home.sessionVariables = {
        DOTNET_ROOT = lib.mkDefault "${dotnetSdk}/share/dotnet";
      };

      # .NET global tools (e.g. the "aspire" CLI) install here.
      home.sessionPath = ["$HOME/.dotnet/tools"];

      # As of .NET 9, Aspire is no longer a workload — it ships as the
      # "Aspire.Cli" global tool plus the "Aspire.ProjectTemplates" package.
      # The old "dotnet workload install aspire" path was removed upstream and
      # silently fails on .NET 9+, which is why Aspire never appeared installed.
      home.activation.dotnetAspire = lib.mkAfter ''
        export PATH="/run/current-system/sw/bin:$HOME/.dotnet/tools:$PATH"
        export DOTNET_ROOT="$(dirname "$(readlink -f "$(command -v dotnet)")")"

        if ! command -v dotnet >/dev/null 2>&1; then
          echo "dotnet not found, skipping Aspire installation."
          exit 0
        fi

        if command -v aspire >/dev/null 2>&1; then
          echo "Updating Aspire CLI..."
          dotnet tool update -g Aspire.Cli 2>/dev/null || echo "Aspire CLI update failed" >&2
        else
          echo "Installing Aspire CLI..."
          dotnet tool install -g Aspire.Cli 2>/dev/null || echo "Aspire CLI installation failed" >&2
        fi

        echo "Installing/updating Aspire project templates..."
        dotnet new install Aspire.ProjectTemplates 2>/dev/null \
          || echo "Aspire templates installation failed" >&2
      '';
    }
  ];

  # Docker Engine (daemon + CLI); add user to the docker group
  virtualisation.docker.enable = true;
  users.users.ac.extraGroups = ["docker"];

  # openfortigui needs passwordless sudo to start VPN tunnels.
  # It re-execs itself as root via QCoreApplication::applicationFilePath(),
  # which under NixOS's Qt wrapper resolves through /proc/self/exe to the
  # real ".openfortigui-wrapped" binary — not the "openfortigui" launcher.
  # The sudoers command must therefore match the wrapped path, otherwise
  # NOPASSWD never applies and sudo falls back to prompting for a password.
  security.sudo.extraRules = [
    {
      groups = ["wheel"];
      commands = [
        {
          command = "${pkgs.openfortigui}/bin/.openfortigui-wrapped --start-vpn *";
          options = ["NOPASSWD" "SETENV"];
        }
      ];
    }
  ];

  # The child process resolves profile paths from main.conf, where they are
  # stored with a "~" prefix and expanded via QDir::homePath(), which reads
  # $HOME. sudo's env_reset rewrites $HOME to /root, so the profile is sought
  # under /root and never found — the process dies instantly with an empty
  # log. openfortigui only passes "sudo -E" when its own sudopresenv setting
  # is enabled, which it is not by default. Preserve $HOME for this one
  # command so the caller's home (and thus the profile path) survives.
  security.sudo.extraConfig = ''
    Cmnd_Alias OPENFORTIGUI_START = ${pkgs.openfortigui}/bin/.openfortigui-wrapped --start-vpn *
    Defaults!OPENFORTIGUI_START env_keep += "HOME"
  '';
}
