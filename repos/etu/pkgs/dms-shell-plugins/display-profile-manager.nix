{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-display-profile-manager";
  version = "0.1.9-unstable-2026-09-18";

  src = fetchFromGitHub {
    owner = "jankelemen";
    repo = "dank-display-profile-manager";
    rev = "e59fd5babc4e99b0c2fb224180fe5b0f8e18b8ca";
    hash = "sha256-PIkoNwtSfbuN0FXv9SvD/2idypTiBm8/n5yGp+CZGBI=";
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
