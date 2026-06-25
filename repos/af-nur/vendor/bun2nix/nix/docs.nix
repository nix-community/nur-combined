{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      serve-book = pkgs.writeShellApplication {
        name = "serve-book";
        runtimeInputs = with pkgs; [
          mdbook
          toml-cli
        ];
        text = ''
          echo "Starting 'mdbook serve' from script bundled with documentation..."

          cargo_toml="programs/bun2nix/Cargo.toml"

          if [[ ! -f "$cargo_toml" ]]; then
              echo "Error: $cargo_toml not found" >&2
              exit 1
          fi

          package_name="$(toml get "$cargo_toml" package.name)"

          if [[ "$package_name" != '"bun2nix"' ]]; then
              echo "Error: Unexpected package name: $package_name (expected 'bun2nix')"
              exit 1
          fi

          if [ ! -d "docs" ]; then
            echo "Error: Documentation folder does not exist in the current repo"
            exit 1
          fi

          mdbook serve docs
        '';
      };
    in
    rec {
      packages.docs = pkgs.stdenv.mkDerivation {
        name = "bun2nix-docs";

        src = "${self}/docs";

        nativeBuildInputs = with pkgs; [
          mdbook
        ];

        buildPhase = ''
          mdbook build
        '';

        installPhase = ''
          mkdir -p $out/lib/bun2nix-docs
          mkdir -p $out/bin

          cp -R ./book/* $out/lib/bun2nix-docs/
          ln -s ${serve-book}/bin/serve-book $out/bin/serve-book
        '';

        meta.mainProgram = "serve-book";
      };
      checks.docs = packages.docs;
    };
}
