{
  self,
  lib,
  config,
  inputs,
  ...
}: {
  flake = {
    nixosConfigurations = lib.genAttrs config.systems (system:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          (builtins.attrValues self.nixosModules)
          ++ [
            {
              # Minimal config to make test configuration build
              boot.loader.grub.devices = ["/dev/vda"];
              fileSystems."/" = {
                device = "tmpfs";
                fsType = "tmpfs";
              };
            }
          ];
      });
  };
}
