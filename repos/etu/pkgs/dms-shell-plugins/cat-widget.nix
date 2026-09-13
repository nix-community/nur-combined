{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-cat-widget";
  version = "0-unstable-2026-04-13";

  src = fetchFromGitHub {
    owner = "xi-ve";
    repo = "cat-dms";
    rev = "eb7b5138b672be3c06445dd80de6bc30c3076030";
    hash = "sha256-KD2G805Hq0K9aPW9Aq4hNo2XKji4kzdc24M4AcRhsPk=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget with an animated running cat for the DankBar whose speed reflects CPU usage";
    homepage = "https://github.com/xi-ve/cat-dms";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
