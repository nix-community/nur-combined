{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  kdePackages,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bluejay";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "EbonJaeger";
    repo = "bluejay";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-cX1QLJCb+GwgcmgOJEOq4wgSaL+29MSQiKbU2MXWhO8=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.bluez-qt
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.kdbusaddons
    kdePackages.ki18n
    kdePackages.kirigami
    kdePackages.kirigami-addons
    kdePackages.qtbase
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "bluejay";
    description = "Bluetooth manager written in Qt";
    homepage = "https://github.com/EbonJaeger/bluejay";
    changelog = "https://github.com/EbonJaeger/bluejay/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
