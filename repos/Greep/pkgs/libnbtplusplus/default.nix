{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  zlib,
  maintainers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnbtplusplus";
  version = "0-unstable-2026-02-25";

  src = fetchFromGitHub {
    owner = "PrismLauncher";
    repo = "libnbtplusplus";
    rev = "687e43031df0dc641984b4256bcca50d5b3f7de3";
    hash = "sha256-7itkptyjoRcXfGLwg1/jxajetZ3a4mDc66+w4X6yW8s=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    zlib
  ];

  cmakeFlags = [
    "-DNBT_BUILD_TESTS=OFF"
    "-DNBT_DEST_DIR=ON"
    "-DLIBRARY_DEST_DIR=lib"
  ];

  # Upstream CMake only installs the library, not the headers.
  postInstall = ''
    pushd $src/include
    find . -type f -exec install -Dm644 {} $out/include/{} \;
    popd
  '';

  meta = with lib; {
    description = "C++ library for Minecraft's file format NBT";
    homepage = "https://github.com/PrismLauncher/libnbtplusplus";
    license = licenses.lgpl3Only;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with maintainers; [ bensuperpc ];
  };
})