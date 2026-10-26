# Gaze page for the KDE Plasma System Settings (`integrations/kde/kcm`).
{
  gaze,
  lib,
  stdenv,
  cmake,
  ninja,
  kdePackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gaze-kcm";
  inherit (gaze) src version;

  sourceRoot = "${finalAttrs.src.name}/integrations/kde/kcm";

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.kcoreaddons
    kdePackages.ki18n
    kdePackages.kcmutils
    kdePackages.kirigami
  ];

  dontWrapQtApps = true;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "Gaze page for the KDE Plasma System Settings";
    homepage = "https://gaze.gundulabs.com";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
})
