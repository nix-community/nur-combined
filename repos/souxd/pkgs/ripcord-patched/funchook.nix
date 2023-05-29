{ stdenv
, lib
, fetchFromGitHub
, gnumake
, cmake
, python3
}:

let
  distorm = (python3.withPackages(ps: [ ps.distorm3 ]));
in
stdenv.mkDerivation rec {
  name = "funcHook";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "kubo";
    repo = "funchook";
    rev = "1.1.2";
    sha256 = "T3loexmITvgTyA340qFs0QaKP7/fz073JW4+oKW8hgg=";
  };

  nativeBuildInputs = [
    gnumake
    cmake
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  buildInputs = [ distorm ];

  meta = with lib; {
    description = "Hook function calls by inserting jump instructions at runtime";
    homepage = "https://github.com/kubo/funchook/";
    license = licenses.gpl2;
    platforms = platforms.linux;
    broken = true;
  };
}
