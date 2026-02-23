{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles;
in
{
  imports = [
    ../os
    ./services
    ./containers
    ./filesystems.nix
    ./gaming.nix
  ];
  config = lib.mkIf cfg.defaults.enable {
    networking = {
      networkmanager.enable = true;
      nftables.enable = true;
    };
    time.timeZone = "America/Chicago";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "C.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "C.UTF-8";
      };
    };
    catppuccin = rec {
      enable = true;
      flavor = "frappe";
      accent = "red";
      tty = {
        enable = true;
        flavor = flavor;
      };
      plymouth.enable = true;
    };
    console.useXkbConfig = true;
    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      nix-ld = {
        enable = true;
        libraries =
          with pkgs;
          (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)
          ++ (appimageTools.defaultFhsEnvArgs.targetPkgs pkgs)
          ++ [
            SDL
            SDL_image
            SDL_mixer
            SDL_ttf
            freeglut
            fuse
            fuse3
            icu
            libclang.lib
            libdbusmenu
            libgcc
            libxcrypt-legacy
            libxml2
            mesa
            pcre
            pcre-cpp
            pcre2
            python3
            stdenv.cc.cc
            xz
          ];
      };
      command-not-found.enable = false;
    };
    services = {
      xserver.xkb = {
        layout = "us";
        options = "ctrl:nocaps";
      };
      pcscd.enable = true;
      udev.packages = with pkgs; [ yubikey-personalization ];
      printing.enable = cfg.gui.enable;
      pipewire = lib.mkIf cfg.gui.enable {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      flatpak.enable = cfg.gui.enable;
      fwupd.enable = true;
      kanata = {
        enable = true;
        keyboards.usbKeyboard = {
          devices = [
            "/dev/input/by-path/pci-0000:27:00.3-usb-0:3:1.0-event-kbd"
            "/dev/input/by-path/pci-0000:27:00.3-usbv2-0:3:1.0-event-kbd"
          ];
          extraDefCfg = "process-unmapped-keys yes";
          config = ''
            (defsrc
              caps
            )

            (defalias
              caps (tap-hold 100 100 esc lctl)
            )

            (deflayer base
              @caps
            )
          '';
        };
      };
    };
    system = {
      stateVersion = "26.05";
      autoUpgrade = {
        enable = true;
        flake = "github:ToyVo/nixcfg";
        persistent = true;
        allowReboot = true;
        rebootWindow = {
          lower = "01:00";
          upper = "05:00";
        };
        randomizedDelaySec = "45min";
      };
    };
    security.rtkit.enable = true;
    nix.optimise.automatic = true;
    boot = {
      loader.systemd-boot.configurationLimit = lib.mkIf config.boot.loader.systemd-boot.enable 3;
      binfmt.registrations.appimage = {
        wrapInterpreterInShell = false;
        interpreter = lib.getExe pkgs.appimage-run;
        recognitionType = "magic";
        offset = 0;
        mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
        magicOrExtension = ''\x7fELF....AI\x02'';
      };
      plymouth.enable = true;
    };
    environment.systemPackages =
      with pkgs;
      [
        cifs-utils
      ]
      ++ lib.optionals (config.system.activationScripts ? setupSecrets) [
        (writeShellScriptBin "sops-nix-system" "${config.system.activationScripts.setupSecrets.text}")
      ];
  };
}
