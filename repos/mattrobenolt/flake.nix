{
  description = "mattrobenolt's nixpkgs";

  nixConfig = {
    extra-substituters = [ "https://mattrobenolt.cachix.org" ];
    extra-trusted-public-keys = [ "mattrobenolt.cachix.org-1:sn1IDSC4OxQvWaOVD4RRcqyKlket5wgb11nd1QII6i8=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
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
      # Filter out "next" to only consider stable versions
      latestGoVersion = builtins.head (
        builtins.sort (a: b: a > b) (builtins.filter (v: v != "next") (builtins.attrNames goVersions))
      );

      # Overlay that adds our custom packages
      overlay =
        _final: prev:
        let
          # Create all go-bin_1_XX packages dynamically
          dynamicGoPackages = builtins.listToAttrs (
            map (majorMinor: {
              name = "go-bin_" + (builtins.replaceStrings [ "." ] [ "_" ] majorMinor);
              value = makeGo prev majorMinor;
            }) (builtins.attrNames goVersions)
          );
        in
        {
          zlint = prev.callPackage ./pkgs/zlint { };
          zlint-unstable = prev.callPackage ./pkgs/zlint/unstable.nix { };
          uvShellHook = prev.callPackage ./pkgs/uv/venv-shell-hook.nix { };
          inbox = prev.callPackage ./pkgs/inbox { };
          zigdoc = prev.callPackage ./pkgs/zigdoc { };
          ziglint = prev.callPackage ./pkgs/ziglint { };
          tracy = prev.callPackage ./pkgs/tracy { };

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

        # Configure treefmt-nix
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs = {
            nixfmt.enable = true; # Uses nixfmt-rfc-style by default
            deadnix.enable = true;
            statix.enable = true;
          };

          settings = {
            global.excludes = [
              ".direnv/**"
              "pkgs/zlint/deps.nix" # Auto-generated file
            ];

            formatter = {
              deadnix.priority = 1; # Remove unused code first
              statix.priority = 2; # Fix anti-patterns second
              nixfmt.priority = 3; # Format last
            };
          };
        };
      in
      {
        packages =
          let
            # Get all go-bin_1_XX package names dynamically
            goPackageNames = map (
              majorMinor: "go-bin_" + (builtins.replaceStrings [ "." ] [ "_" ] majorMinor)
            ) (builtins.attrNames goVersions);
            # Create attrset with all go packages
            goPackages = builtins.listToAttrs (
              map (name: {
                inherit name;
                value = pkgs.${name};
              }) goPackageNames
            );
          in
          {
            inherit (pkgs)
              zlint
              zlint-unstable
              go-bin
              uvShellHook
              inbox
              zigdoc
              ziglint
              tracy
              ;
            default = self.packages.${system}.zlint;
          }
          // goPackages;

        # Formatter for `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

        # Formatting check for CI
        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        # Development shell with Nix tooling
        devShells.default = pkgs.mkShell {
          packages = [
            # Task runner
            pkgs.just

            # For update scripts
            pkgs.python3
            pkgs.zon2nix # Zig dependency generator

            # Unified formatting via treefmt-nix (includes nixfmt, deadnix, statix)
            treefmtEval.config.build.wrapper

            # Nix utilities
            pkgs.nix-tree # Visualize dependency trees
            pkgs.nix-diff # Diff derivations
          ];

          shellHook = ''
            just --list --unsorted
          '';
        };
      }
    );
}
