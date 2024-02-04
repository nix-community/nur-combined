{ lib, stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "neural-amp-modeler-lv2";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = pname;
    rev = version;
    hash = "sha256-sRZngmivNvSWcjkIqcqjjaIgXFH8aMq+/caNroXmzIk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Neural Amp Modeler LV2 plugin implementation";
    longDescription = ''
      Bare-bones implementation of Neural Amp Modeler (NAM) models in an LV2 plugin.
    '';
    homepage = "https://github.com/mikeoliphant/neural-amp-modeler-lv2";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
