{
  description = "xeals's Nix repository";

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

      nixosModules = lib.mapAttrs (_: path: import path) (import ./modules);

      nixosModule = {
        imports = lib.attrValues self.nixosModules;
      };

      overlays = import ./overlays // {
        pkgs = final: prev: import ./pkgs/top-level/all-packages.nix { pkgs = prev; };
      };

      overlay = final: prev: {
        xeals = nixpkgs.lib.composeExtensions self.overlays.pkgs;
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          xPkgs = import ./pkgs/top-level/all-packages.nix { inherit pkgs; };
        in
        lib.filterAttrs
          (attr: drv: builtins.elem system (drv.meta.platforms or [ ]))
          xPkgs);

      apps = forAllSystems (system:
        let
          mkApp = opts: { type = "app"; } // opts;
          pkgs = self.packages.${system};
        in
        {
          alacritty = mkApp { program = "${pkgs.alacritty-ligatures}/bin/alacritty"; };
          protonmail-bridge = mkApp { program = "${pkgs.protonmail-bridge}/bin/protonmail-bridge"; };
          protonmail-bridge-headless = mkApp { program = "${pkgs.protonmail-bridge}/bin/protonmail-bridge"; };
          psst-cli = mkApp { program = "${pkgs.psst}/bin/psst-cli"; };
          psst-gui = mkApp { program = "${pkgs.psst}/bin/psst-gui"; };
          samrewritten = mkApp { program = "${pkgs.samrewritten}/bin/samrewritten"; };
          spotify-ripper = mkApp { program = "${pkgs.spotify-ripper}/bin/spotify-ripper"; };
        });

    };
}
