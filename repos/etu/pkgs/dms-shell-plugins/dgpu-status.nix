{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dgpu-status";
  version = "0-unstable-2026-06-08";

  src = fetchFromGitHub {
    owner = "xantrk";
    repo = "dgpu-sleep-monitor";
    rev = "1d181198fd312f1557617e9ff544031070accb84";
    hash = "sha256-i3tzxxvklE7EWg3SJs+RkiWRpHdtogYt0lQyrzAWexg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget to monitor dGPU power state (D0, D3cold) with cardwire/supergfxctl mode switching";
    homepage = "https://github.com/xantrk/dgpu-sleep-monitor";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
