{ self }:
let
  inherit (self.inputs) stable;
  inherit (self.common.system) stable-system;

in stable-system {
  system = "armv7l-linux";
  modules = [
    "${stable}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
    {
      networking.hostName = "rpi2";
      nixpkgs = {
        config.allowUnsupportedSystem = true;
        crossSystem.system = "armv7l-linux";
      };
      system.stateVersion = "22.11";
    }
  ];
}
