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
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "lemmy-gtk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-krd/w8YTzqQHZYmU3Pt/lKS7eg8n1N8hfL3Rgl1wGfM=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "lemmy_api_common-0.18.0" = "sha256-l4UNO5Obx73nOiVnl6dc+sw2tekDLn2ixTs1GwqdE8I=";
    };
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    gtk4
    libadwaita
    openssl
  ];

  meta = with lib; {
    description = "Native Gtk client for Lemmy";
    homepage = "https://github.com/lemmy-gtk/lemoa";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ colinsane ];
  };
}
