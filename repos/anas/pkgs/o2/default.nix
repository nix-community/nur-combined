{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, alsa-lib
}:

let
  pname = "o2";
  version = "0.3.8";
  owner = "coignard";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = pname;
    rev = "${version}";
    hash = "sha256-9pI+a9RiCxaLAa04MJ9pjb1m0gFHsNoe85MwIg420C8=";
  };

  cargoHash = "sha256-E/BSXBelI89hxsQ0j846gcYIRfy4E0XFm3eNolTHrRI=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ alsa-lib ];

  # There are no tests
  doCheck = false;

  meta = {
    description = "Rust port of the ORCΛ esoteric programming language and terminal livecoding environment";
    homepage = "https://github.com/coignard/o2";
    license = lib.licenses.gpl3Only;
    mainProgram = "o2";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
