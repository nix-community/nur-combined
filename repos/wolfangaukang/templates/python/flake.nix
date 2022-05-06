{
  description = "Template for Python projects that uses Poetry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    poetry2nix.url = "github:nix-community/poetry2nix";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, poetry2nix, utils }:
    let
      # General project settings
      name = "project";
      projectDir = ./.;

    in
    (utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            poetry2nix.overlay
            (nixpkgs.lib.composeExtensions poetry2nix.overlay (final: prev: {
              ${name} = final.poetry2nix.mkPoetryApplication {
                inherit projectDir;
                #inherit overrides projectDir;
              };
            }))
          ];
        };

        # In case you need to run an override on a certain library to build
        #customOverrides = self: super: {
        #  library-name = super.library-name.overrideAttrs(old: {
        #    buildInputs = old.buildInputs ++ [ self.library-to-override ];
        #  });
        #};
        #overrides = pkgs.poetry2nix.overrides.withDefaults (customOverrides);

        # Other project settings
        extraPkgs = with pkgs; [ poetry ];

      in rec {
        # nix build
        packages.${name} = pkgs.${name};
        defaultPackage = packages.${name};

        # nix run (don't create if you are building a library)
        apps.${name} = utils.lib.mkApp { drv = packages.${name}; };
        defaultApp = apps.${name};

        devShell = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          buildInputs = extraPkgs;
        };
      }
    ));
}
