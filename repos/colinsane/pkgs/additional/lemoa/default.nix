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
  version = "unstable-2023-06-25";

  src = fetchFromGitHub {
    owner = "lemmy-gtk";
    repo = pname;
    rev = "bfa01c86093a0ecce9a443df900acfc12c9d9828";
    hash = "sha256-Yr//COIeoGlwPlCnHOzM3BZ+3VhjDocUfPp7nVw3BIM=";
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
