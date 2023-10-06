{ lib, stdenv, fetchFromGitHub, cmake, file, tvision }:

stdenv.mkDerivation rec {
  pname = "turbo";
  version = "2023-06-22";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "turbo";
    rev = "45a02f7de283b404e3be40712adf0f125bda4641";
    hash = "sha256-hN8l536zPCvnBBlVFZGbdjIHQ0Lq3p6m5peXPdNEM6Q=";
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
