{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  kdePackages,
}:

stdenvNoCC.mkDerivation rec {
  meta = with lib; {
    description = "Plasma widget to control Lenovo Legion/Ideapad laptop features (PlasmaVantage)";
    homepage = "https://gitlab.com/Scias/plasmavantage";
    license = licenses.mpl20;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
    mainProgram = null;
  };

  pname = "plasma-vantage";
  version = "0.29";

  src = fetchFromGitLab {
    owner = "Scias";
    repo = "plasmavantage";
    rev = "${version}";
    hash = "sha256-ix26p2Oo64WFI5AF8D+HdlfwVz2wuJ+NfA5th489jPU=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/package $out/share/plasma/plasmoids/com.gitlab.scias.plasmavantage

    runHook postInstall
  '';
}