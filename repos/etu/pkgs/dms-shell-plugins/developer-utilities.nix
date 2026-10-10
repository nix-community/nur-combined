{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-developer-utilities";
  version = "0-unstable-2026-08-14";

  src = fetchFromGitHub {
    owner = "xxyangyoulin";
    repo = "dms-plugin-developer-utilities";
    rev = "b115dcbbe0d82c80190f4fcc255a935e33889f4a";
    hash = "sha256-bpsE5x26Ou7Sfzgv/ttIxfqK3w51x+kSP2dKOIGakTA=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin with encoders, decoders, formatters, and converters for developers";
    homepage = "https://github.com/xxyangyoulin/dms-plugin-developer-utilities";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
