{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-calculator";
  version = "0.3.3-unstable-2026-10-15";

  src = fetchFromGitHub {
    owner = "rochacbruno";
    repo = "DankCalculator";
    rev = "a27b80ad8c3dd42da11af83461674fb362817515";
    hash = "sha256-fw5ySERKzK4iSzZhneIp06zFCP1FnxscbI/COzmPAGQ=";
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
