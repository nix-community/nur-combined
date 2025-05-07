{ self, inputs, lib, ... }:
let
  defaultModules = [
    {
      # Let 'nixos-version --json' know about the Git revision
      system.configurationRevision = self.rev or self.dirtyRev or "dirty";
    }
    {
      nixpkgs.overlays = (lib.attrValues self.overlays) ++ [
        inputs.nur.overlays.default
      ];
    }
    # Include generic settings
    "${self}/modules/nixos"
  ];

  buildHost = name: system: lib.nixosSystem {
    modules = defaultModules ++ [
      {
        nixpkgs.hostPlatform = system;
      }
      "${self}/hosts/nixos/${name}"
    ];
    specialArgs = {
      # Use my extended lib in NixOS configuration
      inherit (self) lib;
      # Inject inputs to use them in global registry
      inherit inputs;
    };
  };
in
{
  flake.nixosConfigurations = lib.mapAttrs buildHost {
    aramis = "x86_64-linux";
    porthos = "x86_64-linux";
  };
}
