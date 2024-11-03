# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:
let
  sway-disable-titlebar-unwrapped = pkgs.sway-unwrapped.overrideAttrs (
    _final: _prev: {
      patches = [
        (pkgs.fetchpatch {
          url = "https://codeberg.org/neuromagus/disable_titlebar_in_sway/raw/branch/main/disable_titlebar_sway1-10.patch";
          hash = "sha256-okX63A9bBPnfYFZTtcQPhyKHUCzaEqtDwT/FNFy0xOM=";
        })
      ];
    }
  );
  sway-lone-titlebar-unwrapped =
    (pkgs.sway-unwrapped.overrideAttrs (
      _final: prev: {
        src = pkgs.fetchFromGitHub {
          owner = "svalaskevicius";
          repo = "sway";
          #rev = "hiding-lone-titlebar-scenegraph";
          rev = "c618290172b745e0d86daa92de479832171c1eb5";
          hash = "sha256-U852/FLD6Ox41QfLXHbB3LagIg+I7th/9P1Opr8Tmpc=";
        };
        mesonFlags = builtins.filter (e: e != "-Dxwayland=enabled") prev.mesonFlags;
      }
    )).override
      {
        enableXWayland = true;
        wlroots = pkgs.wlroots.overrideAttrs (
          _finalAttrs: previousAttrs: {
            version = "0.19.0-dev";
            src = pkgs.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "wlroots";
              repo = "wlroots";
              rev = "015bb8512ee314e1deb858cf7350b0220fc58702";
              hash = "sha256-Awi0iSdtaqAxoXb8EMlZC6gvyW5QtsPrBAl41c2Y9rg=";
            };
            patches = [ ];
            buildInputs = previousAttrs.buildInputs ++ [ pkgs.lcms2 ];
          }
        );
      };
in
{
  inherit sway-disable-titlebar-unwrapped sway-lone-titlebar-unwrapped;

  sauce-code-pro = pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; };
  sway-disable-titlebar = pkgs.sway.override { sway-unwrapped = sway-disable-titlebar-unwrapped; };
  sway-lone-titlebar = pkgs.sway.override { sway-unwrapped = sway-lone-titlebar-unwrapped; };
}
