{
  inputs = {
    # user is expected to define this from their flake via `inputs.nixpkgs.follows = ...`
    nixpkgs = {};
  };
  outputs = { self, nixpkgs }@inputs:
    let
      patchedPkgsFor = system: nixpkgs.legacyPackages.${system}.applyPatches {
        name = "nixpkgs-patched-uninsane";
        version = self.lastModifiedDate;
        src = nixpkgs;
        patches = import ./list.nix {
          inherit (nixpkgs.legacyPackages.${system}) fetchpatch2 fetchurl;
        };
      };
      patchedFlakeFor = system: import "${patchedPkgsFor system}/flake.nix";
      patchedFlakeOutputsFor = system:
        (patchedFlakeFor system).outputs { inherit self; };

      extractBuildPlatform = nixosSystemArgs:
        let
          firstMod = builtins.head nixosSystemArgs.modules;
        in
          firstMod.nixpkgs.buildPlatform or nixosSystemArgs.system;
    in
    {
      lib.nixosSystem = args: (patchedFlakeOutputsFor (extractBuildPlatform args)).lib.nixosSystem args;

      legacyPackages = builtins.mapAttrs
        (system: _:
          (patchedFlakeOutputsFor system).legacyPackages."${system}"
        )
        nixpkgs.legacyPackages;
    };
}
