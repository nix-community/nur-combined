{ stdenv
, lib
, fetchurl
, buildNum
, buildDate
, commit
, device
, sha256
}:

stdenv.mkDerivation rec {
  pname   = "symbiflow-arch-defs-device-${device}";
  version = "${buildDate}-g${commit}";

  src = fetchurl {
    inherit sha256;
    url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${buildNum}/${buildDate}/symbiflow-arch-defs-${device}_test-${commit}.tar.xz";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    cp -r share $out/
  '';

  preferLocalBuild = true;
}
