{
  description = "My nixrepo (afreakk)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      forSpecificSystems = systems: f: lib.genAttrs systems (system: f system);
      forAllSystems = forSpecificSystems supportedSystems;
    in
    {
      lib = {
        inherit forAllSystems forSpecificSystems;
      };
      nixosModules = let x = ((import ./default.nix { pkgs = null; })); in
        {
          # can be used like 
          # imports = (builtins.attrValues myPackages.nixosModules.home-modules);
          home-modules = x.modules;
          system-modules = x.system-modules;
        };
      packages = forAllSystems
        (system:
          lib.filterAttrs (n: v: n != "modules") (import ./default.nix {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
            };
          }));
    };
}
