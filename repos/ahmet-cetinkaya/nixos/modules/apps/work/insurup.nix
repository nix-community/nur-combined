{
  pkgs,
  lib,
  ...
}: let
  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0-bin; # Insurup currently targets the .NET 10 SDK.
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
    gh

    # Database
    # mongodb-compass  # TODO: re-enable once nixpkgs fixes wrap-gapps-hook
    # "bad array subscript" crash on bash 5.3 (buildCommand calls
    # wrapGAppsHook before $output is set; empty-string array subscript
    # errors on bash 5.3+). No upstream fix as of current nixpkgs pin.

    # PDF generation
    wkhtmltopdf

    # Containers
    docker
    docker-compose
    podman-desktop

    # Communication
    teams-for-linux
    slack
  ];

  home-manager.sharedModules = [
    {
      home.sessionVariables = {
        DOTNET_ROOT = lib.mkDefault "${dotnetSdk}/share/dotnet";
      };

      home.sessionPath = ["$HOME/.dotnet/tools"];
    }
  ];

  # Docker Engine (daemon + CLI)
  virtualisation.docker.enable = true;

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
          options = ["NOPASSWD"];
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
