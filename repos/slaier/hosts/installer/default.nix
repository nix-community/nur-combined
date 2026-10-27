{
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  ghosttyBin = "${pkgs.ghostty}/bin/ghostty";

  nixos-fs-init = pkgs.replaceVarsWith {
    src = ./nixos-fs-init.sh;
    dir = "bin";
    isExecutable = true;

    replacements = {
      path = lib.makeBinPath (
        with pkgs;
        [
          btrfs-progs
          coreutils
          dosfstools
          parted
          mount
          umount
        ]
      );
    };
  };

  nixos-fs-mount = pkgs.replaceVarsWith {
    src = ./nixos-fs-mount.sh;
    dir = "bin";
    isExecutable = true;

    replacements = {
      path = lib.makeBinPath (
        with pkgs;
        [
          btrfs-progs
          coreutils
          mount
          umount
        ]
      );
    };
  };
in
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  programs.yazi.enable = true;
  environment.systemPackages = with pkgs; [
    ddrescue
    ghostty
    git
    niri
    nixos-fs-init
    nixos-fs-mount
  ];

  services.speechd.enable = false;

  # The minimal profile disables fontconfig; niri and ghostty need it.
  fonts.fontconfig.enable = lib.mkForce true;

  environment.etc."niri/config.kdl".text = ''
    spawn-at-startup "${ghosttyBin}"

    binds {
        Mod+Return { spawn "${ghosttyBin}"; }
        Mod+Q { close-window; }
        Mod+Shift+E { quit; }
    }
  '';

  services.greetd = {
    enable = true;
    restart = true;
    useTextGreeter = true;
    settings = {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "nixos";
      };
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd ${pkgs.niri}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  nix.settings = {
    auto-allocate-uids = true;
    auto-optimise-store = true;
    experimental-features = [
      "auto-allocate-uids"
      "cgroups"
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://slaier.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "slaier.cachix.org-1:NyXPOqlxuGWgyn0ApNHMopkbix3QjMUAcR+JOjjxLtU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    use-cgroups = true;
  };
}
