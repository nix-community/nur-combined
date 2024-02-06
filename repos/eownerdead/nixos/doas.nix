{ lib, pkgs, config, ... }:
with lib; {
  options.eownerdead.doas = mkEnableOption (mdDoc ''
    Use much simpler and more secure doas instead of sudo.

    Sadly, you can't use this with `nixos-rebulid --use-remote-sudo`.
  '');

  config = mkIf config.eownerdead.doas {
    security = {
      sudo.enable = mkDefault false;
      doas = {
        enable = mkDefault true;
        extraRules = [ { groups = [ "wheel" ]; persist = true; } ];
      };
    };

    environment.systemPackages = [ pkgs.doas-sudo-shim ];
  };
}
