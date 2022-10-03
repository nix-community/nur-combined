{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "gyro";
  version = "unstable-2022-06-17";

  src = fetchFromGitHub {
    owner = "mattnite";
    repo = "gyro";
    rev = "8aea606489741c724e495038c42399bec96d878a";
    sha256 = "sha256-qh/Ggz66u/nSiVPB1O6Q3xAQUP//fB2IDAQysbWuyps=";
  };

  nativeBuildInputs = [ zig-master ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    zig build -Drelease-safe --prefix $out
  '';

  meta = with lib; {
    description = "A Zig package manager";
    homepage = "https://github.com/devins2518/gyro-nix";
    license = licenses.mit;
    maintainers = with maintainers; [ devins2518 ];
    platforms = with platforms; linux ++ darwin;
  };
}
