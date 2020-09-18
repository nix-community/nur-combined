{
  description = "Yoctocell's NUR packages";

  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };


  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

    in
    {
      # Functions
      lib = import ./lib { inherit nixpkgs; };

      # NixOS modules
      modules = import ./modules;

      # Overlays
      overlay = import ./pkgs;

      # Packages
      pkgs = import ./pkgs;

      # Home-manager modules
      hmModules = import ./hm-modules;

      # Nix shell
      devShell = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages."${system}";
        in import ./shell.nix { inherit pkgs; });
    };
}
