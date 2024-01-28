{ lib, stdenv, fetchFromGitHub, cmake, file, tvision }:

stdenv.mkDerivation rec {
  pname = "turbo";
  version = "2024-01-24";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "turbo";
    rev = "f71a08e0adbfe7da38a93c4c02a5ae4dde60797f";
    hash = "sha256-WgovWo3BuRjgb7jO+AcwAWrbB2z4SGeWBVGh5yNTIFE=";
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
