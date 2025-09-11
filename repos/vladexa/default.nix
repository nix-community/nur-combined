# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  crossSystem ? null,
  pkgs ? import <nixpkgs> { inherit crossSystem; },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  mozlz4 = pkgs.callPackage ./pkgs/mozlz4 { };
  arangodb = pkgs.callPackage ./pkgs/arangodb/package.nix {
    stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc13;
  };
  SteamTokenDumper = pkgs.callPackage ./pkgs/SteamTokenDumper/package.nix { };
  h3get = pkgs.callPackage ./pkgs/h3get/package.nix { };
  bgutil-ytdlp-pot-provider =
    let
      version = "1.2.2";
      meta = {
        description = "Proof-of-origin token provider plugin for yt-dlp";
        homepage = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider";
        license = pkgs.lib.licenses.gpl3Plus;
        mainProgram = "bgutil-ytdlp-pot-provider";
        maintainers = [
          {
            email = "vgrechannik@gmail.com";
            name = "Vladislav Grechannik";
            github = "VlaDexa";
            githubId = 52157081;
          }
        ];
      };
      repo = pkgs.fetchFromGitHub {
        owner = "Brainicism";
        repo = "bgutil-ytdlp-pot-provider";
        rev = version;
        hash = "sha256-KKImGxFGjClM2wAk/L8nwauOkM/gEwRVMZhTP62ETqY=";
      };
      plugin = pkgs.fetchzip {
        inherit version meta;
        pname = "bgutil-ytdlp-pot-provider";
        url = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/${version}/bgutil-ytdlp-pot-provider.zip";
        hash = "sha256-vhF2NfkKfscfjm8A/u+hRuXEA4IvtTTnyaMe+AZA8Ig=";
        stripRoot = false;
      };
    in
    {
      inherit plugin;
      server = pkgs.callPackage ./pkgs/bgutil-ytdlp-pot-provider/server/package.nix {
        inherit version meta;
        src = repo;
      };
    };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
