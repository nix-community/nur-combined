{ config, pkgs, ... }:

let
  # Grab our definition if not already available?
  lmt = pkgs.laptop-mode-tools or (pkgs.callPackage ../pkgs/laptop-mode-tools { });
in
{
  environment.systemPackages =  [ lmt ];
  services.udev.packages = [ lmt ];
  systemd.packages = [ lmt ];

  services.acpid.enable = true;
  services.tlp.enable = false; # probably conflicting

  # Eep! Should be a configurable NixOS module instead!
  # For now just symlink the default directory over, doesn't do much
  environment.etc.laptop-mode.source = "${lmt}/etc/laptop-mode";
}

