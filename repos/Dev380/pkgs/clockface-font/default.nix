{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "clockface-font";
  version = "0-unstable-2022-10-04";

  src = fetchFromGitHub {
    owner = "ocodo";
    repo = pname;
    rev = "bad11070c962d328679e9bfec7769fb920097615";
    hash = "sha256-2+kiG5apYMKI5P1o1ahr9BsV87UVWjSmM8S+Vf5MAO0=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype/
    find -name \*.ttf -exec cp -p {} $out/share/fonts/truetype/ \;

    runHook postInstall
  '';

  meta = {
    description = " Icon font for displaying the time ";
    homepage = "https://github.com/ocodo/ClockFace-font";
    license = lib.licenses.free;
  };
}
