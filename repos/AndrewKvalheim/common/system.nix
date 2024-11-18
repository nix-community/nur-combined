{ config, lib, pkgs, ... }:

let
  inherit (config) host;
  inherit (lib) escapeShellArg mkOption removePrefix;
  inherit (lib.types) path;
  inherit (import ./resources/lib.nix { inherit lib; }) frame;

  identity = import ./resources/identity.nix;
  palette = import ./resources/palette.nix { inherit lib pkgs; };
in
{
  imports = [
    ./components/applications.system.nix
    ./components/apt-cache.system.nix
    ./components/backup.system.nix
    ./components/desktop.system.nix
    ./components/keyboard.system.nix
    ./components/locale.system.nix
    ./components/logs.system.nix
    ./components/mail.system.nix
    ./components/networking.system.nix
    ./components/nix.system.nix
    ./components/openpgp.system.nix
    ./components/printer.system.nix
    ./components/scanner.system.nix
    ./components/tor.system.nix
    ./components/users.system.nix
    ./components/virtualization.system.nix
    ./components/wireguard.system.nix
  ];

  options.host = {
    local = mkOption { type = path; };
    resources = mkOption { type = path; };
  };

  config = {
    # Boot
    allowedUnfree = [ "memtest86-efi" ];
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.memtest86.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.plymouth.enable = true;

    # Swap
    zramSwap.enable = true;

    # Filesystems
    boot.initrd.luks = {
      gpgSupport = true;
      devices.pv = {
        device = "/dev/disk/by-partlabel/pv-enc";
        allowDiscards = true;
        fallbackToPassword = true;
        gpgCard.encryptedPass = ./local/resources/luks-passphrase.gpg;
        gpgCard.publicKey = identity.openpgp.asc;
        preOpenCommands = with palette.ansiFormat; ''
          echo $'\n'${escapeShellArg (frame magenta ''
            ${magenta "If found, please contact:"}

              ${cyan "Name:"} ${identity.name.long}
             ${cyan "Email:"} ${identity.email}
             ${cyan "Phone:"} ${identity.phone}
          '')}
        '';
      };
    };
    fileSystems."/".options = [ "compress=zstd:2" "discard=async" "noatime" ];
    fileSystems."/boot".options = [ "umask=0077" ];
    services.btrfs.autoScrub.enable = true;
    boot.tmp.cleanOnBoot = true;

    # Console
    console.packages = with pkgs; [ terminus_font ];
    console.font = "ter-v32n";
    console.colors = map (removePrefix "#") (with palette.hex; [
      "#000000" red green yellow blue orange purple platinum
      white-dim red green yellow blue orange purple white
    ]);

    # Power
    systemd.ctrlAltDelUnit = "poweroff.target";

    # Authentication
    security.pam.u2f = {
      enable = true;
      appId = "pam://${host.name}";
      authFile = "/etc/u2f-mappings";
      control = "sufficient";
      cue = true;
    };

    # Authorization
    security.sudo.extraRules = [{
      groups = [ "wheel" ];
      commands = [
        { command = "/run/current-system/sw/bin/btrfs balance start --enqueue -dusage=50 -musage=50 /"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/nix-channel --update"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/poweroff"; options = [ "NOPASSWD" ]; }
      ];
    }];

    # SSH
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    # SMART monitoring
    services.smartd = {
      enable = true;
      notifications.mail.enable = true;
    };

    # Firmware updates
    hardware.enableRedistributableFirmware = true;
    services.fwupd.enable = true;

    # Profiling
    services.sysprof.enable = true;
  };
}
