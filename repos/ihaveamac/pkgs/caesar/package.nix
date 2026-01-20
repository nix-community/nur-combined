{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "caesar";
  version = "0.4.2-unstable-2022-08-16";

  src = fetchFromGitHub {
    owner = "kr3nshaw";
    repo = pname;
    rev = "3874856c08c8c04e2fc7e3d1417301469a411b2f";
    hash = "sha256-464/mhD+6N25/Qbq8ssv4GXbE5TetvlbvC5kHUFd3Jg=";
  };

  patches = [
    ./include-cstdint.patch
    ./remove-unnecessary-typedef.patch
  ];

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];

  installPhase = ''
    mkdir -p $out/bin
    cp caesar${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "A tool that extracts the contents of Citrus Sound Archives";
    homepage = "https://github.com/kr3nshaw/caesar";
    license = licenses.gpl3;
    platforms = platforms.all;
    mainProgram = "caesar";
  };
}
