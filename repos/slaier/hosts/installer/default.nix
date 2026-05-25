{
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
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
  environment.systemPackages = with pkgs; [
    git
    nixos-fs-init
    nixos-fs-mount
  ];
  nix.settings = {
    auto-allocate-uids = true;
    auto-optimise-store = true;
    experimental-features = "auto-allocate-uids cgroups nix-command flakes";
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
