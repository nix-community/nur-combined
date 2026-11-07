{
  pkgs,
  lib,
  ...
}: let
  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0-bin; # Insurup currently targets the .NET 10 SDK.

  # Must match the domain set with `./dev-env domain set`.
  devDomain = "insurup.dev";
  devDnsInterface = "devdns0";
  devDnsAddress = "169.254.53.53";
  devDnsOctets = lib.concatStringsSep " " (lib.splitString "." devDnsAddress);

  # Machine-local module (internal CA, VPN DNS) — gitignored, never committed.
  # A git flake never sees ignored files, so it is imported by ABSOLUTE path,
  # which pure evaluation forbids: it only loads under --impure (apply.sh).
  secretModule = /home/ac/Configs/nixos/modules/apps/work/insurup-secret.nix;
  loadSecret = !lib.inPureEvalMode && builtins.pathExists secretModule;
in {
  imports = lib.optional loadSecret secretModule;

  warnings = lib.optional (!loadSecret) ''
    insurup-secret.nix was not loaded (pure evaluation or file missing):
    the InsurUp CA and VPN DNS are NOT configured. Rebuild with --impure.
  '';

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

    # Local HTTPS for ./dev-env domain (certutil from nssTools lets mkcert
    # register its CA in the Chrome/Firefox NSS stores)
    mkcert
    nssTools

    # Database
    mongosh
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

  # ./dev-env domain gives every branch instance its own *.insurup.dev
  # hostnames, and /etc/hosts (read-only on NixOS) has no wildcards. A tiny
  # local resolver answers every *.insurup.dev with 127.0.0.1 instead.
  #
  # The global resolved config (modules/core/dpi.nix) enforces DNSOverTLS and
  # DNSSEC, which dnsmasq supports neither of, so it cannot be a global
  # nameserver. It gets its own dummy link instead (resolved refuses to take
  # DNS settings on loopback), routed for insurup.dev alone; every other name
  # keeps using the encrypted upstreams.
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      listen-address = devDnsAddress;
      bind-interfaces = true;
      no-resolv = true;
      address = "/${devDomain}/127.0.0.1";
    };
  };

  networking.networkmanager.unmanaged = ["interface-name:${devDnsInterface}"];

  # resolvectl is not used: v262 sends link settings through systemd-networkd,
  # which this host does not run (NetworkManager owns the links). The resolved
  # D-Bus API takes the same settings directly. The link and its settings are
  # lost when resolved restarts, hence bindsTo.
  systemd.services.insurup-dev-dns = {
    description = "Route ${devDomain} to the local dev resolver";
    wantedBy = ["multi-user.target" "systemd-resolved.service"];
    bindsTo = ["systemd-resolved.service"];
    after = ["systemd-resolved.service"];
    before = ["dnsmasq.service"];
    requiredBy = ["dnsmasq.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "-${pkgs.iproute2}/bin/ip link delete ${devDnsInterface}";
    };
    script = ''
      ip=${pkgs.iproute2}/bin/ip
      $ip link show ${devDnsInterface} >/dev/null 2>&1 || $ip link add ${devDnsInterface} type dummy
      $ip address replace ${devDnsAddress}/32 dev ${devDnsInterface}
      $ip link set ${devDnsInterface} up

      index=$(cat /sys/class/net/${devDnsInterface}/ifindex)
      resolved() {
        ${pkgs.systemd}/bin/busctl call org.freedesktop.resolve1 \
          /org/freedesktop/resolve1 org.freedesktop.resolve1.Manager "$@"
      }
      resolved SetLinkDNS 'ia(iay)' "$index" 1 2 4 ${devDnsOctets}
      resolved SetLinkDomains 'ia(sb)' "$index" 1 ${devDomain} true
      resolved SetLinkDefaultRoute ib "$index" false
      resolved SetLinkDNSOverTLS is "$index" no
      resolved SetLinkDNSSEC is "$index" no
    '';
  };

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
