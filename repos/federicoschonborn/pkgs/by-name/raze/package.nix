{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  libvpx,
  SDL2,
  zmusic,
  nix-update-script,

  withGtk3 ? true,
  gtk3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "raze";
  version = "1.12pre";

  src = fetchFromGitHub {
    owner = "ZDoom";
    repo = "Raze";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-uzi1ArsKnymf1GjLwwTBwJiwbwTlCfQoHb7gAJKBtbo=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    libvpx
    SDL2
    zmusic
  ] ++ lib.optional withGtk3 gtk3;

  cmakeFlags = [ (lib.cmakeBool "DYN_GTK" false) ];

  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "raze";
    description = "Build engine port backed by GZDoom tech. Currently supports Duke Nukem 3D, Blood, Shadow Warrior, Redneck Rampage and Powerslave/Exhumed";
    homepage = "https://github.com/ZDoom/Raze";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
