{ config, lib, pkgs, ... }:
with lib;
let
  secretPath = ../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);

  isAuthorized = p: builtins.isAttrs p && p.authorized or false;
  authorizedKeys = lists.optionals secretCondition (
    attrsets.mapAttrsToList
      (name: value: value.key)
      (attrsets.filterAttrs (name: value: isAuthorized value) (import secretPath).ssh)
  );

  hasConfigVirtualizationContainers = builtins.hasAttr "containers" config.virtualisation;
  isContainersEnabled = if hasConfigVirtualizationContainers then config.virtualisation.containers.enable else false;
in
{
  users.users.vincent = {
    createHome = true;
    uid = 1000;
    description = "Vincent Demeester";
    extraGroups = [ "wheel" "input" ]
      ++ optionals config.profiles.desktop.enable [ "audio" "video" "lp" "scanner" "networkmanager" ]
      ++ optionals config.networking.networkmanager.enable [ "networkmanager" ]
      ++ optionals config.profiles.docker.enable [ "docker" ]
      ++ optionals config.profiles.buildkit.enable [ "buildkit" ]
      ++ optionals config.profiles.virtualization.enable [ "libvirtd" ];
    shell = mkIf config.programs.zsh.enable pkgs.zsh;
    isNormalUser = true;
    openssh.authorizedKeys.keys = authorizedKeys;
    # FIXME change this ?
    initialPassword = "changeMe";
    # FIXME This might be handled differently by programs.podman, …
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  /*
  virtualisation = mkIf isContainersEnabled {
    containers.users = [ "vincent" ];
  };
  */
  security.pam.services.vincent.fprintAuth = config.services.fprintd.enable;

  home-manager.users.vincent = lib.mkMerge (
    [
      (import ./core)
      (import ./mails { hostname = config.networking.hostName; pkgs = pkgs; })
    ]
    ++ optionals config.profiles.dev.enable [ (import ./dev) ]
    ++ optionals config.profiles.desktop.enable [ (import ./desktop) ]
    ++ optionals config.services.xserver.desktopManager.gnome3.enable [ (import ./desktop/gnome.nix) ]
    ++ optionals (config.networking.hostName == "wakasu") [{
      programs.google-chrome.enable = true;
      home.packages = with pkgs; [
        openvpn
        krb5
        libosinfo
        virtmanager
        thunderbird
        asciinema
        gnome3.zenity # use rofi instead
        oathToolkit
        my.kubernix
      ];
    }]
    ++ optionals config.profiles.laptop.enable [{
      # FIXME move this in its own file
      programs.autorandr.enable = true;
    }]
    ++ optionals config.profiles.docker.enable [{
      home.packages = with pkgs; [ docker docker-compose ];
    }]
    ++ optionals (isContainersEnabled && config.profiles.dev.enable) [
      (import ./containers)
    ]
  );
}
