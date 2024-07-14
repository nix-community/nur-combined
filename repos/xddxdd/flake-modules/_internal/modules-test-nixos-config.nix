{
  self,
  lib,
  config,
  inputs,
  ...
}:
let
  enumerateList = builtins.foldl' (
    l: ll:
    l
    ++ [
      {
        index = builtins.length l;
        value = ll;
      }
    ]
  ) [ ];
in
{
  imports = [ ./ci-outputs.nix ];

  flake = {
    nixosConfigurations = lib.genAttrs config.systems (
      system:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = (builtins.attrValues self.nixosModules) ++ [
          {
            # Minimal config to make test configuration build
            boot.loader.grub.devices = [ "/dev/vda" ];
            fileSystems."/" = {
              device = "tmpfs";
              fsType = "tmpfs";
            };
            nixpkgs.config.allowUnfree = true;
            system.stateVersion = lib.trivial.release;

            # Add all CI packages
            environment.etc = (
              lib.mapAttrs' (
                _n: v: lib.nameValuePair "ci-packages/${v.name}" { source = v; }
              ) self.ciPackages.${system}
            );
          }
        ];
      }
    );
  };
}
