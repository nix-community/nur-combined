{
  inputs = {
    nixpkgs = {};
  };
  outputs = { self, nixpkgs }@inputs:
    let
      patchedPkgsFor = system: nixpkgs.legacyPackages.${system}.applyPatches {
        name = "nixpkgs-patched-uninsane";
        src = nixpkgs;
        patches = import ./list.nix {
          inherit (nixpkgs.legacyPackages.${system}) fetchpatch fetchurl;
        };
      };
      patchedFlakeFor = system: import "${patchedPkgsFor system}/flake.nix";
      patchedFlakeOutputsFor = system:
        (patchedFlakeFor system).outputs { inherit self; };
    in
    {
      legacyPackages = builtins.mapAttrs
        (system: _:
          (patchedFlakeOutputsFor system).legacyPackages."${system}"
        )
        nixpkgs.legacyPackages;
    };
}
