{ stdenv, fetchFromGitHub, zig_0_14 }:

stdenv.mkDerivation rec {
  pname = "mist";
  version = "0.0.14";

  nativeBuildInputs = [ zig_0_14.hook ];

  src = fetchFromGitHub {
    owner  = "mgord9518";
    repo   = "mist";
    rev    = "85039ced1133d8f023cba3f5cb6f0867dee3f19a";
    sha256 = "sha256-GN4krkA2Su3WZoopBk7757SwVilluDcIB2k2tyLEdII=";
    downloadToTemp = true;
  };

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
}
