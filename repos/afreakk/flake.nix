{
  description = "My nixrepo (afreakk)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: lib.genAttrs supportedSystems (system: f system);
    in
    {
      nixosModules = ((import ./default.nix { pkgs = null; }).modules);
      nixosModule = {
        imports = lib.attrValues self.nixosModules;
      };
      packages = forAllSystems
        (system:
          lib.filterAttrs (n: v: n != "modules") (import ./default.nix {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }));
    };
}
