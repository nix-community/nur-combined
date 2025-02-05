{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
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
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "ZDoom";
    repo = "Raze";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-8kr+BLwfTQ0kx6TMqu1AUxiCgvwJd2urZqJ09FH48lo=";
  };

  patches = lib.optional (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "14") (
    # make gcc14 happy
    fetchpatch {
      url = "https://github.com/ZDoom/Raze/commit/f3cad8426cd808be5ded036ed12a497d27d3742e.patch";
      hash = "sha256-TMx5gFmcuSQbVPjpBnKgK7EluqPSWhLF+TU8ZRaL7LE=";
    }
  );

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

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "raze";
    description = "Build engine port backed by GZDoom tech. Currently supports Duke Nukem 3D, Blood, Shadow Warrior, Redneck Rampage and Powerslave/Exhumed";
    homepage = "https://github.com/ZDoom/Raze";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
