{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  meta = with lib; {
    description = "A rewrite of Panel Transparency Button for Plasma 6";
    homepage = "https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6";
    license = licenses.gpl2Only;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
    mainProgram = null;
  };

  pname = "panel-transparency-toggle-plasma6";
  version = "unstable-739c70f";

  src = fetchFromGitHub {
    owner = "sanjay-kr-commit";
    repo = "panelTransparencyToggleForPlasma6";
    rev = "739c70f";
    hash = "sha256-1VKLkGw9jxJvYDoUgkRjnCT6+ol2dJAmppM61lvVOi8=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids
    cp -r $src $out/share/plasma/plasmoids/org.kde.panel.transparency.toggle

    runHook postInstall
  '';
}