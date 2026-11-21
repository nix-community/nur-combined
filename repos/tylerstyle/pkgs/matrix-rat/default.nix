{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  perl,
  aws-lc,
  sqlite,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "matrix-rat";
  version = "1.0.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "matrix-rat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-arEc3yQtYFSHq6jzvFEx04jGwJ5S7hSpzQtra7kDerk=";
  };

  cargoHash = "sha256-SvsEY/jMJcg4GLHHd0grKR9xDvMdtwrYrfypO71IFxo=";

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
  ];

  # nixpkgs tells the -sys crates to link the system libraries instead of building their
  # bundled copies
  buildInputs = [
    aws-lc
    sqlite
    zstd
  ];

  # The test suite runs in the project's own CI script; skipping it here halves the build
  doCheck = false;

  # A launcher entry (it also offers matrix-rat for `matrix:` links) and the icon: in
  # colour, and as a line drawing for places that want a symbolic one
  postInstall = ''
    install -Dm644 contrib/matrix-rat.desktop $out/share/applications/matrix-rat.desktop
    install -Dm644 assets/icon.svg $out/share/icons/hicolor/scalable/apps/matrix-rat.svg
    for size in 64 128 256 512; do
      install -Dm644 assets/icon-$size.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/matrix-rat.png
    done
    install -Dm644 assets/icon-outline.svg \
      $out/share/icons/hicolor/symbolic/apps/matrix-rat-symbolic.svg
  '';

  meta = {
    description = "Mouse-friendly, themeable Matrix client for the terminal";
    homepage = "https://github.com/tylerstyle/matrix-rat";
    changelog = "https://github.com/tylerstyle/matrix-rat/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ] ++ lib.optionals (lib.maintainers ? tylerstyle) [ lib.maintainers.tylerstyle ];
    mainProgram = "matrix-rat";
    platforms = lib.platforms.linux;
    # matrix-sdk 0.19 needs Rust 1.96 (rust-version in Cargo.toml); nixos-26.05 ships 1.95
    broken = lib.versionOlder rustPlatform.rust.rustc.version "1.96";
  };
})
