{ lib
, rustPlatform
, fetchFromGitHub
, glib
, atk
, gtk3
, pkg-config
}:

rustPlatform.buildRustPackage rec {

  pname = "filepicker";
  version = "1.0.1";

  cargoSha256 = "sha256-aal7ppFkCpNc+QTS4Qklsb9WfJ65QqG6p1eOskiX+/Q=";

  src = fetchFromGitHub {
    owner = "paulrouget";
    repo = "static-filepicker";
    rev = "v${version}";
    hash = "sha256-7sRzf3SA9RSBf4O36olXgka8c6Bufdb0qsuTofVe55s=";
  };

  buildInputs = [
    glib
    atk
    gtk3 # gdk
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  meta = with lib; {
    description = "file picker";
    homepage = "https://github.com/paulrouget/static-filepicker";
    license = licenses.gpl2;
    maintainers = [];
  };
}
