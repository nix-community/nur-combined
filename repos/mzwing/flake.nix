{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    mkUpdateApps = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      update = pkgs.writeShellApplication {
        name = "update-packages";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.git
          pkgs.nix
          pkgs.nvfetcher
          pkgs.python3
        ];
        text = ''
          export LANG=en_US.UTF-8
          key_flags=()
          [[ -f "$HOME/Secrets/nvfetcher.toml" ]] && key_flags+=(-k "$HOME/Secrets/nvfetcher.toml")
          [[ -f secrets.toml ]] && key_flags+=(-k secrets.toml)
          export PYTHONPATH="${pkgs.python3Packages.packaging}/lib/python${pkgs.python3.pythonVersion}/site-packages:''${PYTHONPATH:-}"

          nix flake update
          nvfetcher "''${key_flags[@]}" -c nvfetcher.toml -o _sources "$@"

          while IFS= read -r script; do
            echo "Executing $script"
            chmod +x "$script"
            "$script"
          done < <(find pkgs -type f -name 'update.*' -print | sort)
        '';
      };
      updateHashes = pkgs.writeShellApplication {
        name = "update-package-hashes";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.git
          pkgs.gnugrep
          pkgs.nix
          pkgs.nix-update
        ];
        text = ''
          files="$(
            grep --recursive --files-with-matches --include='*.nix' \
              --extended-regexp '[[:alnum:]_]+Hash = "sha256-' pkgs || true
          )"
          [[ -z "$files" ]] && exit 0

          while IFS= read -r file; do
            attr="$(basename "$(dirname "$file")")"
            if nix eval ".#packages.${system}.$attr.pname" >/dev/null 2>&1; then
              echo "Updating hashes for $attr"
              nix-update --flake "$attr" --version skip --override-filename "$file"
            else
              echo "Skipping $attr: no matching flake package" >&2
            fi
          done <<<"$files"
        '';
      };
    in {
      update = {
        type = "app";
        program = "${update}/bin/update-packages";
        meta.description = "Update package sources with nvfetcher";
      };
      update-hashes = {
        type = "app";
        program = "${updateHashes}/bin/update-package-hashes";
        meta.description = "Update package dependency hashes with nix-update";
      };
    };
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });
    packages = forAllSystems (system: let
      platform = nixpkgs.legacyPackages.${system}.stdenv.hostPlatform;
    in
      nixpkgs.lib.filterAttrs
      (_: package: nixpkgs.lib.isDerivation package && nixpkgs.lib.meta.availableOn platform package)
      self.legacyPackages.${system});
    apps.x86_64-linux = mkUpdateApps "x86_64-linux";
    nixosModules = import ./nixos-modules;
    # homeModules = import ./home-modules;
    # darwinModules = import ./darwin-modules;
    # flakeModules = import ./flake-modules;
  };
}
