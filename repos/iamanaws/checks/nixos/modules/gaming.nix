{
  pkgs,
  inputs,
  nixosModules,
  ...
}:
let
  standalone = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixosModules.gaming
      {
        nixpkgs.hostPlatform = pkgs.stdenv.hostPlatform.system;
        nixpkgs.config.allowUnfree = true;
      }
    ];
  };
  hardened = standalone.extendModules {
    modules = [
      inputs.nix-mineral.nixosModules.nix-mineral
      {
        nix-mineral.enable = true;
        nix-mineral.preset = [ "maximum" ];
      }
    ];
  };
in
assert standalone.config.programs.steam.enable;
assert !(standalone.config ? nix-mineral);
assert hardened.config.programs.steam.enable;
assert !hardened.config.nix-mineral.kernel-modules.disable.joydev;
assert hardened.config.nix-mineral.kernel-modules.disable.joystick-drivers;
true
