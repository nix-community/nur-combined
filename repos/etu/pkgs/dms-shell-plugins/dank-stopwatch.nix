{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-stopwatch";
  version = "0-unstable-2026-10-20";

  src = fetchFromGitHub {
    owner = "NordicsSys";
    repo = "dankStopwatch";
    rev = "97c0350fb28e2b89f2f3456ddfd98f2791ebfe81";
    hash = "sha256-j1Zqn1Yc/U2bSQXhZOww33Ks14F3S66jriWsYqah+Ug=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell modern glassmorphic stopwatch pill with laps, copy time, and a polished popout toolbar";
    homepage = "https://github.com/NordicsSys/dankStopwatch";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
