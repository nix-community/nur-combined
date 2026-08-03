{
  description = "📦 NUR packages from codgician.";

  nixConfig = {
    allow-import-from-derivation = "true";
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.codgician.me/serenitea-pot"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nur-packages:AbWm/DsIy5+TtVaW6GhiZX98nU6y5913NqjEXeeV8mA="
    ];
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

      # Shared tooling shell for local development and every CI harness command.
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
              # Pi package review/repair agent
              pi-coding-agent
            ];

            # Make sure update scripts can find the repository root.
            shellHook = ''
              export NIX_PATH="nixpkgs=${pkgs.path}"
              export PI_OFFLINE=1
              export PI_TELEMETRY=0

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
