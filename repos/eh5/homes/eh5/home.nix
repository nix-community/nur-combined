{ config, lib, pkgs, ... }:
let
  clang14-tools =
    let
      inherit (pkgs.llvmPackages_14) clang-unwrapped clang;
    in
    pkgs.clang-tools.overrideAttrs (_: {
      version = lib.getVersion clang-unwrapped;
      inherit clang;
    });
in
{
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      substituters = lib.mkForce [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://eh5.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "eh5.cachix.org-1:pNWZ2OMjQ8RYKTbMsiU/AjztyyC8SwvxKOf6teMScKQ="
      ];
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;
  programs.man.enable = false;

  systemd.user.tmpfiles.rules = [
    "d %C/netease-cloud-music/CachedSongs - - - 5d -"
  ];

  targets.genericLinux.enable = true;

  xdg.mime.enable = false;

  home.language.base = "zh_CN.UTF-8";

  home.packages = with pkgs; [
    cachix
    clang14-tools
    netease-cloud-music
    nix-gfx-mesa
    rnix-lsp
    ssh-to-age
  ];
}
