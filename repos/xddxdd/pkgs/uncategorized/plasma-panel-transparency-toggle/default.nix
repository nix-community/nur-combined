{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-panel-transparency-toggle";
  version = "0-unstable-2024-04-17";
  src = fetchFromGitHub {
    owner = "sanjay-kr-commit";
    repo = "panelTransparencyToggleForPlasma6";
    rev = "739c70ffde6bb7670d57d3507804408ae13edf25";
    hash = "sha256-1VKLkGw9jxJvYDoUgkRjnCT6+ol2dJAmppM61lvVOi8=";
  };
  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids/org.kde.panel.transparency.toggle
    cp -r * $out/share/plasma/plasmoids/org.kde.panel.transparency.toggle
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Rewrite of Panel Transparency Button for Plasma 6";
    homepage = "https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6";
    license = lib.licenses.gpl2Only;
  };
})
