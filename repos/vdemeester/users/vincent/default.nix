{ config, lib, pkgs, ... }:

let
  inherit (lib) importTOML attrsets hasAttr optionals versionAtLeast mkIf;
  metadata = importTOML ../../ops/hosts.toml;
  hasSSHAttr = name: value: hasAttr "ssh" value;
  authorizedKeys = attrsets.mapAttrsToList
    (name: value: value.ssh.pubkey)
    (attrsets.filterAttrs hasSSHAttr metadata.hosts);

  hasConfigVirtualizationContainers = builtins.hasAttr "containers" config.virtualisation;
  isContainersEnabled = if hasConfigVirtualizationContainers then config.virtualisation.containers.enable else false;
in
{
  warnings = if (versionAtLeast config.system.nixos.release "21.11") then [ ] else [ "NixOS release: ${config.system.nixos.release}" ];
  sops.secrets.u2f_keys = mkIf (config.modules.hardware.yubikey.enable && config.modules.hardware.yubikey.u2f) {
    path = "/home/vincent/.config/Yubico/u2f_keys";
    owner = "vincent";
  };
  users.users.vincent = {
    createHome = true;
    uid = 1000;
    description = "Vincent Demeester";
    extraGroups = [ "wheel" "input" ]
      ++ optionals config.networking.networkmanager.enable [ "networkmanager" ]
      ++ optionals config.modules.desktop.enable [ "audio" "video" ]
      # ++ optionals config.profiles.scanning.enable [ "lp" "scanner" ]
      ++ optionals config.networking.networkmanager.enable [ "networkmanager" ]
      ++ optionals config.virtualisation.docker.enable [ "docker" ]
      ++ optionals config.virtualisation.buildkitd.enable [ "buildkit" ]
      ++ optionals config.modules.virtualisation.libvirt.enable [ "libvirtd" ]
      ++ optionals config.services.nginx.enable [ "nginx" ];
    shell = mkIf config.programs.zsh.enable pkgs.zsh;
    isNormalUser = true;
    openssh.authorizedKeys.keys = authorizedKeys
      ++ metadata.ssh.keys.vincent
      ++ metadata.ssh.keys.root;
    initialPassword = "changeMe";
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  nix = {
    settings = {
      trusted-users = [ "vincent" ];
    };
    sshServe.keys = authorizedKeys;
  };

  security = {
    pam = {
      # Nix will hit the stack limit when using `nixFlakes`.
      loginLimits = [
        { domain = config.users.users.vincent.name; item = "stack"; type = "-"; value = "unlimited"; }
      ];
    };
  };

  # Enable user units to persist after sessions end.
  system.activationScripts.loginctl-enable-linger-vincent = lib.stringAfter [ "users" ] ''
    ${pkgs.systemd}/bin/loginctl enable-linger ${config.users.users.vincent.name}
  '';

  # To use nixos config in home-manager configuration, use the nixosConfig attr.
  # This make it possible to import the whole configuration, and let each module
  # load their own.
  # FIXME(vdemeester) using nixosConfig, we can get the NixOS configuration from
  # the home-manager configuration. This should help play around the conditions
  # inside each "home-manager" modules instead of here.
  home-manager.users.vincent = lib.mkMerge
    (
      [
        (import ./core)
        (import ./mails { hostname = config.networking.hostName; pkgs = pkgs; })
      ]
      ++ optionals config.modules.editors.emacs.enable [
        (import ./dev/emacs.nix)
      ]
      ++ optionals config.modules.dev.enable [
        (import ./dev)
        # TODO Move it elsewhere ? 
        (import ./containers/kubernetes.nix)
        (import ./containers/openshift.nix)
        (import ./containers/tekton.nix)
        {
          # Enable only on dev, could do something better than this longterm 😀
          services.keybase.enable = true;
        }
      ]
      ++ optionals config.modules.dev.containers.enable [
        (import ./containers)
      ]
      ++ optionals config.modules.desktop.enable [ (import ./desktop) ]
      ++ optionals (config.networking.hostName == "wakasu" || config.networking.hostName == "aomi") [
        {
          home.packages = with pkgs; [
            libosinfo
            asciinema
            oathToolkit
            p7zip
          ];
        }
      ]
      # ++ optionals config.virtualisation.docker.enable [
      #   {
      #     home.packages = with pkgs; [ docker docker-compose dive ];
      #   }
      # ]
      #++ optionals config.profiles.redhat.enable [{
      #  home.file.".local/share/applications/redhat-vpn.desktop".source = ./redhat/redhat-vpn.desktop;
      #  home.packages = with pkgs; [ gnome3.zenity oathToolkit ];
      #}]
    );
}
