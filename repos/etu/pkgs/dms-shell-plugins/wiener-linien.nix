{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-wiener-linien";
  version = "0-unstable-2026-06-08";

  src = fetchFromGitHub {
    owner = "wolfsblu";
    repo = "dms-wiener-linien";
    rev = "fac494339b07bf650dc6a9b12cc64e6823131b9d";
    hash = "sha256-LQbCoef0cj+33hpXFdrLA7PIlsr3s1w47ftyVHYAvok=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget to track departure times of Wiener Linien public transit";
    homepage = "https://github.com/wolfsblu/dms-wiener-linien";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
