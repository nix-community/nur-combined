{
  description = "mattrobenolt's nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    let
      # Load Go versions and hashes
      goVersions = builtins.fromJSON (builtins.readFile ./pkgs/go/versions.json);
      goHashes = builtins.fromJSON (builtins.readFile ./pkgs/go/hashes.json);

      # Helper to create a Go package for a specific version
      makeGo =
        prev: majorMinor:
        let
          version = goVersions.${majorMinor};
          hashes = goHashes.${version};
        in
        prev.callPackage ./pkgs/go {
          inherit version hashes;
        };

      # Get the latest Go version (highest minor version)
      latestGoVersion = builtins.head (builtins.sort (a: b: a > b) (builtins.attrNames goVersions));

      # Overlay that adds our custom packages
      overlay =
        _final: prev:
        let
          # Create all go-bin_1_XX packages dynamically
          dynamicGoPackages = builtins.listToAttrs (
            map
              (majorMinor: {
                name = "go-bin_" + (builtins.replaceStrings [ "." ] [ "_" ] majorMinor);
                value = makeGo prev majorMinor;
              })
              (builtins.attrNames goVersions)
          );
        in
        {
          zlint = prev.callPackage ./pkgs/zlint { };
          zlint-unstable = prev.callPackage ./pkgs/zlint/unstable.nix { };
          uvShellHook = prev.callPackage ./pkgs/uv/venv-shell-hook.nix { };

          # Latest Go version as go-bin (automatically uses the highest version)
          go-bin = makeGo prev latestGoVersion;
        }
        // dynamicGoPackages;
    in
    {
      # Export the overlay for others to use
      overlays.default = overlay;

      # Project templates
      templates = {
        go = {
          path = ./templates/go;
          description = "Go development environment";
        };

        zig = {
          path = ./templates/zig;
          description = "Zig development environment";
        };

        bun = {
          path = ./templates/bun;
          description = "Bun development environment";
        };

        rust = {
          path = ./templates/rust;
          description = "Rust development environment";
        };

        python = {
          path = ./templates/python;
          description = "Python development environment";
        };
      };

      # Default template
      defaultTemplate = self.templates.go;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages =
          let
            # Get all go-bin_1_XX package names dynamically
            goPackageNames = map
              (
                majorMinor: "go-bin_" + (builtins.replaceStrings [ "." ] [ "_" ] majorMinor)
              )
              (builtins.attrNames goVersions);
            # Create attrset with all go packages
            goPackages = builtins.listToAttrs (
              map
                (name: {
                  inherit name;
                  value = pkgs.${name};
                })
                goPackageNames
            );
          in
          {
            inherit (pkgs) zlint zlint-unstable go-bin uvShellHook;
            default = self.packages.${system}.zlint;
          }
          // goPackages;

        # Development shell with Nix tooling
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Task runner
            just

            # For update scripts
            python3
            zon2nix # Zig dependency generator

            # Nix formatter
            nixpkgs-fmt # Official nixpkgs formatter

            # Nix linters
            statix # Lints and suggests anti-patterns
            deadnix # Find and remove unused code

            # Nix utilities
            nix-tree # Visualize dependency trees
            nix-diff # Diff derivations
          ];

          shellHook = ''
            just --list --unsorted
            echo ""
          '';
        };
      }
    );
}
