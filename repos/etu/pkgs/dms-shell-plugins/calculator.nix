{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-calculator";
  version = "0.3.3-unstable-2026-10-01";

  src = fetchFromGitHub {
    owner = "rochacbruno";
    repo = "DankCalculator";
    rev = "c9fbbe921e9afeb92f4e92390e9fc05f006f0373";
    hash = "sha256-dqFTvNogWsqK82EhgMIbJB70R5TgcRiA3Elx1LkSia8=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin that evaluates mathematical expressions and copies results to clipboard";
    homepage = "https://github.com/rochacbruno/DankCalculator";
    license = licenses.agpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
