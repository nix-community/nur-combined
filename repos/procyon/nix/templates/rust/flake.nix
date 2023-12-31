{
  description = "Rust Project [Template]";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { system, self', inputs', config, lib, pkgs, ... }:
        let
          stdenv =
            if pkgs.stdenv.isLinux
            then pkgs.stdenv
            else pkgs.clangStdenv;
          makeOverridableProject = old: config:
            let
              wrapped =
                pkgs.runCommand
                  old.name
                  {
                    inherit (old) pname version;
                    meta = old.meta or { };
                    passthru =
                      (old.passthru or { })
                      // {
                        unwrapped = old;
                      };
                    nativeBuildInputs = [ pkgs.makeWrapper ];
                    makeWrapperArgs = config.makeWrapperArgs or [ ];
                  }
                  ''
                    cp -rs --no-preserve=mode,ownership ${old} $out
                  '';
            in
            wrapped
            // {
              override = makeOverridableProject old;
              passthru =
                wrapped.passthru
                // {
                  wrapper = old: makeOverridableProject old config;
                };
            };
          filteredSource =
            let
              pathsToIgnore = [
                ".envrc"
                ".ignore"
                ".github"
                ".gitignore"
                ".gitattributes"
                "rust-toolchain.toml"
                "README.md"
                "default.nix"
                "flake.nix"
                "flake.lock"
              ];
              ignorePaths = path: type:
                let
                  inherit (inputs.nixpkgs) lib;
                  components = lib.splitString "/" path;
                  relPathComponents = lib.drop 4 components;
                  relPath = lib.concatStringsSep "/" relPathComponents;
                in
                lib.all (p: ! (lib.hasPrefix p relPath)) pathsToIgnore;
            in
            builtins.path {
              path = toString ./.;
              filter = ignorePaths;
              name = "${pname}-source";
            };
          rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          craneLibMSRV = (inputs.crane.mkLib pkgs).overrideToolchain rustToolchain;
          inherit (craneLibMSRV.crateNameFromCargoToml { cargoToml = ./Cargo.toml; }) pname version;
          craneLibStable = (inputs.crane.mkLib pkgs).overrideToolchain pkgs.pkgsBuildHost.rust-bin.stable.latest.default;
          commonArgs = {
            inherit stdenv pname version;
            src = filteredSource;
            buildInputs = [ ]
              ++ lib.optional stdenv.isLinux pkgs.lldb
              ++ lib.optional stdenv.isDarwin pkgs.darwin.apple_sdk.frameworks.CoreFoundation;
          };
          cargoArtifacts = craneLibMSRV.buildDepsOnly commonArgs;
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.rust-overlay.overlays.default ];
          };

          packages = {
            default = self'.packages."${pname}";
            "${pname}" = makeOverridableProject self'.packages."${pname}-unwrapped" { };
            "${pname}-unwrapped" = craneLibStable.buildPackage (commonArgs // { inherit cargoArtifacts; });
          };

          devShells.default = pkgs.mkShell {
            name = "${pname}-shell";
            inputsFrom = builtins.attrValues self'.checks;
            shellHook = ''
              export RUST_BACKTRACE="1"
            '';
          };

          checks = {
            inherit (self'.packages) default;
            fmt = craneLibMSRV.cargoFmt commonArgs;
            doc = craneLibMSRV.cargoDoc (commonArgs // { inherit cargoArtifacts; });
            test = craneLibMSRV.cargoTest (commonArgs // { inherit cargoArtifacts; });
            deny = craneLibMSRV.cargoDeny (commonArgs // { inherit cargoArtifacts; });
            audit = craneLibMSRV.cargoAudit (commonArgs // {
              inherit cargoArtifacts;
              inherit (inputs) advisory-db;
            });
            clippy = craneLibMSRV.cargoClippy (commonArgs // {
              inherit cargoArtifacts;
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            });
          };
        };
    };
}
