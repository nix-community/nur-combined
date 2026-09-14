{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-take-a-break";
  version = "1.4.4-unstable-2026-08-23";

  src = fetchFromGitHub {
    owner = "hthienloc";
    repo = "dms-take-a-break";
    rev = "38e5a1cc12cd797a0d55d26d47c905fab9fa180b";
    hash = "sha256-y2XG9XRx1JBugIfgsftm6W5I/2TcBpaS451Ab0meeiI=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell gentle companion widget that reminds you to rest your eyes with short and long breaks";
    homepage = "https://github.com/hthienloc/dms-take-a-break";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
