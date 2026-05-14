{ lib, pkgs, ... }:

let
  inherit (lib) removePrefix;

  palette = import ../library/palette.lib.nix { inherit lib pkgs; };
in
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
    };

    plymouth.enable = true;
  };

  console = {
    packages = with pkgs; [ terminus_font ];

    font = "ter-v32n";
    colors = map (removePrefix "#") (
      (with palette.hex.ansi; [ black red green yellow blue magenta cyan white ]) ++
      (with palette.hex.ansi.bright; [ black red green yellow blue magenta cyan white ])
    );
  };
}
