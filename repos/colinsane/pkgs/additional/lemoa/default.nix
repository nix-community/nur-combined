{ lib
, fetchFromGitHub
, gdk-pixbuf
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
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "lemmy-gtk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-7tq9XP79GXnIoibrZugdir79P14qJevTzY44fC3R7cA=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "lemmy_api_common-0.18.0" = "sha256-l4UNO5Obx73nOiVnl6dc+sw2tekDLn2ixTs1GwqdE8I=";
    };
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    gdk-pixbuf
    glib
    graphene
    gtk4
    libadwaita
    openssl
    pango
  ];

  meta = with lib; {
    description = "Native Gtk client for Lemmy";
    homepage = "https://github.com/lemmy-gtk/lemoa";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ colinsane ];
  };
}
