{ lib, stdenv, fetchFromGitHub, cmake, ncurses }:

stdenv.mkDerivation rec {
  pname = "tvision";
  version = "2024-01-24";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "tvision";
    rev = "0917f04206fcfa1973dc49547af74e7399241899";
    hash = "sha256-BWDMpHR7/ViKZtyZwLJEfgpHIUjkRfc/DRWiQTeo9ME=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ ncurses ];

  meta = with lib; {
    description = "A modern port of Turbo Vision 2.0, the classical framework for text-based user interfaces";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
