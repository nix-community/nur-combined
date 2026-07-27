{
  description = "SignalRidge NUR packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./default.nix { inherit pkgs; }
      );

      overlays.default = final: prev: {
        clinvk = final.callPackage ./pkgs/clinvk { };
      };
    };
}
