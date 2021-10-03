{
  lib, stdenv,
  fetchFromGitHub,
  cmake,
  ...
} @ args:

stdenv.mkDerivation rec {
  pname = "libltnginx";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "libltnginx";
    rev = "96698a667740ac45ca4571a04a6cfe39caf926c0";
    sha256 = "159z1bq5cycsik8mzjr25fqs72pkyq2nax63qd26qai4vnj84zq3";
    fetchSubmodules = true;
  };

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/lib
    mv libltnginx.so $out/lib
  '';

  nativeBuildInputs = [
    cmake
  ];
}
