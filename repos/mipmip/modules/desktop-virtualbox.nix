{ config, lib, pkgs, unstable, ... }:

{

  nixpkgs.config =
    {
      packageOverrides = pkgs: {
        virtualbox = unstable.virtualbox.override {
          inherit (config.boot);
        };
      };

      # Make sure that the Virtualbox Oracle Extensions are installed.

      # Make sure that unfree packages are available.
      allowUnfree = true;
    };


  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "pim" ];
}

