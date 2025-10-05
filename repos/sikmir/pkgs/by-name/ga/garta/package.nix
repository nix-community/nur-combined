{
  lib,
  stdenv,
  rustPlatform,
  rust,
  fetchFromGitLab,
  pkg-config,
  atk,
  cairo,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  openssl,
  pango,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "garta";
  version = "0.1.0-unstable-2021-02-08";

  src = fetchFromGitLab {
    owner = "timosaarinen";
    repo = "garta";
    rev = "9c873318ba9d2dad8990b6439cf93c99e2702215";
    hash = "sha256-Swlhej0Q8SAWgpl/fh2pgTS/AWGtFh5wdE1O6RlBV60=";
  };

  patches = [ ./parseconfig.patch ];

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-cFhNoH4AoF2wJHDc5MRwo5BYkbzhS/p8zgL10Y/+EOw=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    openssl
    pango
  ];

  postPatch = ''
    substituteInPlace ./configure.sh \
      --replace-fail "target/release" "target/${stdenv.hostPlatform.rust.rustcTargetSpec}/release"

    patchShebangs configure.sh
  '';

  configurePhase = ''
    export PKG_CONFIG_PATH='${lib.makeSearchPathOutput "dev" "lib/pkgconfig" finalAttrs.buildInputs}'

    ./configure.sh --prefix $out

    substituteInPlace install.sh \
      --replace-fail "/etc/firejail" "$out/etc/firejail"

    patchShebangs install.sh
  '';

  env.NIX_LDFLAGS = "-L${zlib}/lib";

  installPhase = ''
    ./install.sh
    install -Dm644 ${./inkatlas.json} $out/share/garta/maps/inkatlas.json
    rm -fr $out/etc
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Geo-bookmarking, GPX viewer, analyzer and editor for GTK3";
    homepage = "https://gitlab.com/timosaarinen/garta";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
