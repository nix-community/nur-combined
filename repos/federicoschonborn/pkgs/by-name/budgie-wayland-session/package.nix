{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (_: {
  pname = "budgie-wayland-session";
  version = "0-unstable-2025-03-15";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "budgie-wayland-session";
    rev = "96472e671eaba0f19124d96d5517009ea5cf9f70";
    hash = "sha256-CdhKLYo5Qy0lJClIV0WlnUCuSfrqYnypb5vnm+sRHDc=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    (lib.cmakeBool "SDDM" true)
    (lib.cmakeBool "KWIN_DEVELOPMENT" true)
    (lib.cmakeBool "MAGPIE_DEVELOPMENT" true)
    (lib.cmakeBool "MIRIWAY_DEVELOPMENT" true)
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "budgie-wayland-session";
    description = "Wayland session for the Budgie Desktop using a variety of window managers";
    homepage = "https://github.com/BuddiesOfBudgie/budgie-wayland-session";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
