{
  description = "Ethan Edwards NUR repo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    sysfo = {
      url = "github:ethancedwards8/sysfo";
      flake = false;
    };

    dmenu = {
      url = "gitlab:ethancedwards/dmenu-config";
      flake = false;
    };
    firefox-addons-generator = {
      url = "gitlab:rycee/nixpkgs-firefox-addons";
      flake = false;
    };
    st = {
      url = "gitlab:ethancedwards/st-config";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
        forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      packages = forAllSystems (system: import ./default.nix {
        inputs = inputs;
        # inherit inputs;
        pkgs = import nixpkgs { inherit system; };
      });

      devShell = forAllSystems (system: nixpkgs.legacyPackages."${system}".callPackage ./pkgs/devShell.nix { });
    };
}
