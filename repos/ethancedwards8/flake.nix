{
  description = "Ethan Edwards NUR repo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
      supportedSystems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
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
