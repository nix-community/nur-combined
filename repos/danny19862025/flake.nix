{
  description = "Spotlight native Linux productivity launcher";

  # Immutable input revision; update deliberately when refreshing dependencies.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/09063bd1f2b36fd9fd793c36dfade7bd40a93dfc";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      packageFor = system:
        let
          pkgs = import nixpkgs { inherit system; };
          # gdk-pixbuf keeps PNG and JPEG inside the library, but WebP and the
          # other formats need a loaders cache that also covers the separate
          # loader packages.
          gdkPixbufLoaders = pkgs.gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
            extraLoaders = [ pkgs.webp-pixbuf-loader ];
          };
        in pkgs.rustPlatform.buildRustPackage {
          pname = "spotlight";
          version = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package.version;
          src = pkgs.lib.cleanSource ./.;
          cargoHash = "sha256-BuWTx7ohs8cDYRFMY8yklAPjbE5j20ULbrtTaIz2vxg=";

          nativeBuildInputs = [ pkgs.pkg-config pkgs.wrapGAppsHook4 ];
          buildInputs = [
            pkgs.gtk4
            pkgs.sqlite
            pkgs.gsettings-desktop-schemas
            # Provides the pixbuf loaders through GDK_PIXBUF_MODULE_FILE.
            pkgs.gdk-pixbuf
            pkgs.webp-pixbuf-loader
          ];
          nativeCheckInputs = [
            pkgs.git pkgs.ripgrep pkgs.gzip pkgs.vips pkgs.ffmpeg
            pkgs.zbar pkgs.poppler-utils pkgs.python3 pkgs.curl
          ];

          postPatch = ''
            substituteInPlace src/guide_topics.rs src/productivity_smoke.rs \
              --replace '#!/bin/sh' '#!${pkgs.runtimeShell}'
          '';

          preCheck = ''
            export GDK_PIXBUF_MODULE_FILE=${gdkPixbufLoaders}
          '';

          postInstall = ''
            # Read by the gapps wrapper hook below, so it has to be set here.
            export GDK_PIXBUF_MODULE_FILE=${gdkPixbufLoaders}
            install -Dm644 docs/community-plugins.toml $out/lib/spotlight/community-plugins.toml
            install -Dm644 packaging/spotlight.desktop $out/share/applications/spotlight.desktop
            substituteInPlace $out/share/applications/spotlight.desktop \
              --replace-fail 'Exec=spotlight' "Exec=$out/bin/spotlight"
            install -Dm644 assets/spotlight.svg $out/share/icons/hicolor/scalable/apps/spotlight.svg
            for license in LICENSE assets/UNICODE-LICENSE.txt assets/QRCODEGEN-LICENSE.txt; do
              install -Dm644 "$license" "$out/share/licenses/spotlight/$(basename "$license")"
            done
          '';
          preFixup = ''
            gappsWrapperArgs+=(
              --set GSK_RENDERER cairo
              # The autostart entry has to start the wrapped process.
              --set SPOTLIGHT_EXECUTABLE $out/bin/spotlight
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.python3 pkgs.curl pkgs.ripgrep pkgs.xdg-utils ]}
            )
          '';

          meta = {
            description = "A keyboard-first native Linux productivity launcher";
            homepage = "https://github.com/danny19862025/spotlight";
            license = pkgs.lib.licenses.mit;
            mainProgram = "spotlight";
            platforms = systems;
          };
        };
    in {
      packages = forAllSystems (system: {
        spotlight = packageFor system;
        default = self.packages.${system}.spotlight;
      });
      checks = forAllSystems (system: { inherit (self.packages.${system}) spotlight; });
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.spotlight ];
            packages = [ pkgs.cargo pkgs.rustc pkgs.rustfmt pkgs.clippy ];
            GSK_RENDERER = "cairo";
            GDK_PIXBUF_MODULE_FILE = pkgs.gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
              extraLoaders = [ pkgs.webp-pixbuf-loader ];
            };
          };
        });
    };
}
