{
  lib,
  stdenv,
  fetchFromGitLab,
  kdePackages,
  cmake,
  ninja,
  pkg-config,
  linux-pam,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "plasma-login-manager";
  version = "0-unstable-2025-04-03";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "davidedmundson";
    repo = "plasma-login-manager";
    rev = "54822b34d31982641fde44e6075007e9dfe068b7";
    hash = "sha256-pnOVML62G5Nri5Z45YrDZvpB29hrWN2zUlQpQw+2j40=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.qttools
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    linux-pam
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.kauth
    kdePackages.kcmutils
    kdePackages.kconfig
    kdePackages.kdbusaddons
    kdePackages.ki18n
    kdePackages.kio
    kdePackages.kpackage
    kdePackages.kwindowsystem
    kdePackages.layer-shell-qt
    kdePackages.libplasma
    kdePackages.plasma-workspace
  ];

  # Mostly copied from https://github.com/NixOS/nixpkgs/blob/698214a32beb4f4c8e3942372c694f40848b360d/pkgs/applications/display-managers/sddm/unwrapped.nix#L62-L85
  cmakeFlags = [
    # Set UID_MIN and UID_MAX so that the build script won't try
    # to read them from /etc/login.defs (fails in chroot).
    # The values come from NixOS; they may not be appropriate
    # for running SDDM outside NixOS, but that configuration is
    # not supported anyway.
    "-DUID_MIN=1000"
    "-DUID_MAX=29999"

    "-DSYSTEMD_SYSTEM_UNIT_DIR=${placeholder "out"}/lib/systemd/system"
    "-DSYSTEMD_SYSUSERS_DIR=${placeholder "out"}/lib/sysusers.d"
    "-DSYSTEMD_TMPFILES_DIR=${placeholder "out"}/lib/tmpfiles.d"
  ];

  strictDeps = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    mainProgram = "plasma-login-manager";
    description = "Plasma Login Manager provides the backend for Plasma's login experience";
    homepage = "https://invent.kde.org/davidedmundson/plasma-login-manager";
    license = with lib.licenses; [
      cc-by-30
      gpl2Plus
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
