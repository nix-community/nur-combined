{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-display-profile-manager";
  version = "0.1.8-unstable-2026-07-15";

  src = fetchFromGitHub {
    owner = "jankelemen";
    repo = "dank-display-profile-manager";
    rev = "497ea32fe48fe76835d52f7a6794d516cde15b48";
    hash = "sha256-CzEGtqtT82Ba9sXQKFNp3x8wibHLgJQVU+sIa1hmRiM=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget for selecting DMS output profiles";
    homepage = "https://github.com/jankelemen/dank-display-profile-manager";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
