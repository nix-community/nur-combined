{
  description = "📦 NUR packages from codgician.";

  nixConfig = {
    allow-import-from-derivation = "true";
    sandbox = "relaxed"; # For certain packages on aarch64-darwin
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      inherit (nixpkgs) lib;
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      mypkgs = (
        system:
        import ./default.nix {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        }
      );
    in
    {
      formatter = forAllSystems (
        system:
        with nixpkgs.legacyPackages.${system};
        writeShellApplication {
          name = "formatter";
          runtimeInputs = [
            treefmt
            nixfmt
            mdformat
            yamlfmt
          ];
          text = ''
            exec ${lib.getExe treefmt} "$@"
          '';
        }
      );

      # Tooling shell for package update scripts, OpenCode automation, and CI checks.
      # Keep every command used by those workflows pinned through this flake.
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Core
              git
              cacert
              coreutils
              # CI/CD harness validation
              actionlint
              check-jsonschema
              shellcheck
              zizmor
              # Update-script utilities (union of all pkgs/*/update.sh deps)
              curl
              jq
              gnused
              gnugrep
              nodejs
              # Nix source/hash prefetchers for recomputing fixed-output hashes
              nix-update
              nix-prefetch-git
              prefetch-npm-deps
              nurl
              # OpenCode package review/repair agent
              opencode
            ];

            # Make sure update scripts can find the repository root.
            shellHook = ''
              export NIX_PATH="nixpkgs=${pkgs.path}"
            '';
          };
        }
      );

      legacyPackages = forAllSystems mypkgs;

      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      # NixOS VM tests live under ./tests and are surfaced in flake `checks`
      # so `nix flake check` runs them and CI can build them by name. Each
      # test is also referenced from its package's `passthru.tests`. VM
      # tests are Linux-only, so checks are restricted to Linux systems.
      checks = lib.genAttrs (lib.filter (lib.hasSuffix "-linux") systems) (
        system: self.legacyPackages.${system}.tests or { }
      );

      nixosModules = import ./modules;
    };
}
