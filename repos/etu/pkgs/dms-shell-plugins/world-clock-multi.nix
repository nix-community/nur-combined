{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-world-clock-multi";
  version = "0-unstable-2026-06-11";

  src = fetchFromGitHub {
    owner = "szabolcsf";
    repo = "dms-world-clock-multi";
    rev = "7229958de9781b20fb27f48944f0f77bf891bf22";
    hash = "sha256-39iqKERTdo+Qcv/2LssFPO8mPji4FqYs12KkS0SjNtg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget showing up to 5 timezones on the DankBar, toggling between showing all at once or cycling through them at a configurable interval";
    homepage = "https://github.com/szabolcsf/dms-world-clock-multi";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
