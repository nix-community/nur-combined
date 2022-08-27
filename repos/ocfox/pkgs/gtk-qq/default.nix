{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, libiconv
, installShellFiles
, pkg-config
, openssl
, gtk4
, libadwaita
, sqlite
, grpc-tools
, meson
, glib
, ninja
, libxml2
}:
rustPlatform.buildRustPackage rec {
  pname = "gtk-qq";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "lomirus";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-a1hGUnkQ+mEdv8Q2R2QEkSB+ojDZll2DpLpx+Vakngs=";
  };

  cargoSha256 = "sha256-J1mQiqn8i9IhZg7kIakMzjvg1ho9g9vAjqrFoNCtlR8=";

  RUSTC_BOOTSTRAP = 1;

  buildInputs = [ openssl gtk4 libadwaita sqlite ];
  nativeBuildInputs = [ pkg-config grpc-tools meson glib ninja libxml2 ];

  configurePhase = ''
    export HOME=$TEMPDIR
    export XDG_DATA_HOME=$TEMPDIR
    meson setup builddir 
    meson compile -C builddir
  '';

  buildPhase = ''
    cargo build --release
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp target/release/gtk-qq $out/bin
  '';

  meta = with lib; {
    description = "Unofficial Linux QQ client, based on GTK4 and libadwaita, developed with Rust and Relm4.";
    homepage = "https://github.com/lomirus/gtk-qq";
    license = licenses.agpl3Only;
  };
}

