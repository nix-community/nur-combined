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
  version = "0-unstable-2025-04-11";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "davidedmundson";
    repo = "plasma-login-manager";
    rev = "1695dc21ed1fb53e85f99fb1430e3c50b21fbde1";
    hash = "sha256-PSlqDa1Psuzf/2NmaSSVshP8sVV7XnJo+6m8Lc7QsPQ=";
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
