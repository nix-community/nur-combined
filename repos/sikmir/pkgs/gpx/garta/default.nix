{ lib, stdenv, rustPlatform, rust, fetchFromGitLab, pkg-config
, atk, cairo, gdk-pixbuf, glib, gtk3, harfbuzz, openssl, pango, zlib
}:

rustPlatform.buildRustPackage rec {
  pname = "garta";
  version = "2021-02-08";

  src = fetchFromGitLab {
    owner = "timosaarinen";
    repo = "garta";
    rev = "9c873318ba9d2dad8990b6439cf93c99e2702215";
    hash = "sha256-Swlhej0Q8SAWgpl/fh2pgTS/AWGtFh5wdE1O6RlBV60=";
  };

  patches = [ ./parseconfig.patch ];

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-azOKcrq5iQ9RsLL2RaKbJV1eMs43pj0Sok4ZwJ183EI=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ atk cairo gdk-pixbuf glib gtk3 harfbuzz openssl pango ];

  postPatch = ''
    substituteInPlace ./configure.sh \
      --replace "target/release" "target/${rust.toRustTargetSpec stdenv.hostPlatform}/release"

    patchShebangs configure.sh
  '';

  configurePhase = ''
    export PKG_CONFIG_PATH='${lib.makeSearchPathOutput "dev" "lib/pkgconfig" buildInputs}'

    ./configure.sh --prefix $out

    substituteInPlace install.sh \
      --replace "/etc/firejail" "$out/etc/firejail"

    patchShebangs install.sh
  '';

  NIX_LDFLAGS = "-L${zlib}/lib";

  installPhase = ''
    ./install.sh
    install -Dm644 ${./inkatlas.json} $out/share/garta/maps/inkatlas.json
    rm -fr $out/etc
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Geo-bookmarking, GPX viewer, analyzer and editor for GTK3";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
