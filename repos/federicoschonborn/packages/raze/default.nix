{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  libvpx,
  libwebp,
  SDL2,
  zmusic,
  nix-update-script,

  withGtk3 ? false,
  gtk3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "raze";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "ZDoom";
    repo = "Raze";
    rev = finalAttrs.version;
    hash = "sha256-lXBH2uLAV7wF/sO5t86EB8gwubWkpm56A6E42wJX68I=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    libvpx
    libwebp
    SDL2
    zmusic
  ] ++ lib.optional withGtk3 gtk3;

  cmakeFlags = [ (lib.cmakeBool "DYN_GTK" false) ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "raze";
    description = "Build engine port backed by GZDoom tech. Currently supports Duke Nukem 3D, Blood, Shadow Warrior, Redneck Rampage and Powerslave/Exhumed";
    homepage = "https://github.com/ZDoom/Raze";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
