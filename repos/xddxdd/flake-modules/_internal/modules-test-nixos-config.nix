{
  self,
  lib,
  config,
  inputs,
  ...
}:
let
  mkNixOSConf =
    name: system: packagesAttr:
    lib.nameValuePair name (
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
            environment.etc = lib.mapAttrs' (
              _n: v: lib.nameValuePair "ci-packages/${v.name}" { source = v; }
            ) packagesAttr.${system};
          }
        ];
      }
    );
in
{
  imports = [ ./ci-outputs.nix ];

  flake = {
    nixosConfigurations = builtins.listToAttrs (
      lib.flatten (
        builtins.map (system: [
          (mkNixOSConf "${system}" system self.ciPackages)
          (mkNixOSConf "${system}-cuda" system self.ciPackagesWithCuda)
        ]) config.systems
      )
    );
  };
}
