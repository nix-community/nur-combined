{ lib, stdenv, fetchFromGitHub, cmake, file, tvision }:

stdenv.mkDerivation rec {
  pname = "turbo";
  version = "0-unstable-2024-02-05";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "turbo";
    rev = "3251358bb06e277309b9ae678f1c88c315c7f856";
    hash = "sha256-5EdVrzu9MxXTfQSfenjPQJ8pBizRAhhAAxyA3aObCvU=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    file # libmagic
    tvision
  ];

  cmakeFlags = [
    (lib.cmakeBool "TURBO_USE_SYSTEM_TVISION" true)
  ];

  meta = with lib; {
    description = "An experimental text editor based on Scintilla and Turbo Vision";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
