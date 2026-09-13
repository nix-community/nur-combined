{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-stopwatch";
  version = "0-unstable-2026-05-25";

  src = fetchFromGitHub {
    owner = "NordicsSys";
    repo = "dankStopwatch";
    rev = "76004b9f2f08da010a80096c5d48e6ef41390fdc";
    hash = "sha256-PuE65aisBVp+J7t5UYlc2B7uf4Ci+ScNX9iyo08xIVg=";
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
