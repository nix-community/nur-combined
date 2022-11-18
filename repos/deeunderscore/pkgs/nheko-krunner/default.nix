{ mkDerivation
, lib
, fetchFromGitHub
, cmake
, extra-cmake-modules
, krunner }:

mkDerivation rec {
  pname = "nheko-krunner";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "LorenDB";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-IbDNyGerqUBE+00TD+uQbHWmPX9kK5aipOGTJjuVlZc=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];

  buildInputs = [ krunner ];

  meta = with lib; {
    description = "KRunner integration for the Nheko Matrix client";
    homepage = "https://github.com/LorenDB/nheko-krunner";
    # TODO: verify this, source contains both mentions of GPL and LGPL
    license = licenses.gpl3Plus;
  };

}