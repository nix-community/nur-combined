{ config, lib, pkgs, ... }:

let
  inherit (config) host;
  inherit (lib) escapeShellArg findFirst last removePrefix;

  identity = import ../library/identity.lib.nix { inherit lib; };
  palette = import ../library/palette.lib.nix { inherit lib pkgs; };

  terminus-sizes = [ 12 14 16 18 20 22 24 28 32 ]; # https://terminus-font.sourceforge.net/
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

    plymouth.enable = false; # Expose contact information

    initrd.systemd.services.contact-information = {
      unitConfig.DefaultDependencies = false;
      wantedBy = [ "systemd-ask-password-console.service" ];
      before = [ "systemd-ask-password-console.service" ];

      script = ''
        echo ${escapeShellArg identity.contactNotice} > /dev/console
      '';

      serviceConfig.Type = "oneshot";
    };
  };

  console = {
    packages = with pkgs; [ terminus_font ];

    font =
      let
        target = 14 * host.metrics.displayDensity;
        size = findFirst (s: s >= target) (last terminus-sizes) terminus-sizes;
      in
      "ter-v${toString size}n";

    colors = map (removePrefix "#") (
      (with palette.hex.ansi; [ black red green yellow blue magenta cyan white ]) ++
      (with palette.hex.ansi.bright; [ black red green yellow blue magenta cyan white ])
    );
  };
}
