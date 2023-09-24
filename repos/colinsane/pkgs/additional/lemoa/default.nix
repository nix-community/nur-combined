{ lib
, fetchFromGitHub
, gdk-pixbuf
, gitUpdater
, glib
, graphene
, gtk4
, libadwaita
, openssl
, pango
, pkg-config
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "lemoa";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "lemmy-gtk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-0xMdshQ12mV93r5UwxRLgYsIj97GgxmDDMEisam29HI=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    gtk4
    libadwaita
    openssl
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Native Gtk client for Lemmy";
    homepage = "https://github.com/lemmy-gtk/lemoa";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ colinsane ];
  };
}
