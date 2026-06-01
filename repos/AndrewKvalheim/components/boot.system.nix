{ lib, pkgs, ... }:

let
  inherit (lib) escapeShellArg removePrefix;

  identity = import ../library/identity.lib.nix { inherit lib; };
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

    font = "ter-v32n";
    colors = map (removePrefix "#") (
      (with palette.hex.ansi; [ black red green yellow blue magenta cyan white ]) ++
      (with palette.hex.ansi.bright; [ black red green yellow blue magenta cyan white ])
    );
  };
}
