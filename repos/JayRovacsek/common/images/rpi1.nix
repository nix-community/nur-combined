{ self }:
let
  inherit (self.inputs) stable;

  inherit (self.common.system) stable-system;

in stable-system {
  system = "armv6l-linux";
  modules = [
    "${stable}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
    {
      networking.hostName = "rpi1";
      nixpkgs = {
        config.allowUnsupportedSystem = true;
        crossSystem.system = "armv6l-linux";
      };
      system.stateVersion = "22.11";
    }
  ];
}
