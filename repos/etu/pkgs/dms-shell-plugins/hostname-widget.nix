{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-hostname-widget";
  version = "0-unstable-2026-05-14";

  src = fetchFromGitHub {
    owner = "irunatbullets";
    repo = "hostname-widget";
    rev = "a3b633de3d13d0d58ab34250bfc3e8fe527c896c";
    hash = "sha256-ARL4EK8Chgryhk7vEpVwbF7s5d8JLNLWJtmfMm6zGeg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget that displays your hostname";
    homepage = "https://github.com/irunatbullets/hostname-widget";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
