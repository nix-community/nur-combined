{
  inputs = {
    # user is expected to define this from their flake via `inputs.nixpkgs.follows = ...`
    nixpkgs = {};
  };
  outputs = { self, nixpkgs, variant ? "master" }@inputs:
    let
      patchedPkgsFor = system: nixpkgs.legacyPackages.${system}.applyPatches {
        name = "nixpkgs-patched-uninsane";
        version = self.lastModifiedDate;
        src = nixpkgs;
        patches = builtins.filter (p: p != null) (
          nixpkgs.legacyPackages."${system}".callPackage ./list.nix { } variant nixpkgs.lastModifiedDate
        );
      };
      patchedFlakeFor = system: import "${patchedPkgsFor system}/flake.nix";
      patchedFlakeOutputsFor = system:
        (patchedFlakeFor system).outputs { self = self._forSystem system; };

      extractBuildPlatform = nixosSystemArgs:
        builtins.foldl'
          (acc: mod: ((mod.nixpkgs or {}).buildPlatform or {}).system or acc)
          (nixosSystemArgs.system or null)
          (nixosSystemArgs.modules or []);
    in
    {
      # i attempt to mirror the non-patched nixpkgs flake outputs,
      # however the act of patching is dependent on the build system (can't be done in pure nix),
      # hence a 100% compatible interface has to be segmented by `system`:
      _forSystem = system: {
        inherit (patchedFlakeOutputsFor system) lib;
        legacyPackages = builtins.mapAttrs
          (system': _:
            (patchedFlakeOutputsFor (if system != null then system else system'))
              .legacyPackages."${system'}"
          )
          nixpkgs.legacyPackages;
      };

      # although i can't expose all of the patched nixpkgs outputs without knowing the `system` to use for patching,
      # several outputs learn about the system implicitly, so i can expose those:
      lib.nixosSystem = args: (
        self._forSystem (extractBuildPlatform args)
      ).lib.nixosSystem args;

      legacyPackages = (self._forSystem null).legacyPackages;
    };
}
