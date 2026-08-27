{
  cmake,
  corrosion,
  cargo,
  fetchFromGitHub,
  fontconfig,
  lib,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  ninja,
  patchelf,
  pkg-config,
  rustPlatform,
  rustc,
  stdenv,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "slint";
  version = "1.17.1";

  src = fetchFromGitHub {
    owner = "slint-ui";
    repo = "slint";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eK4endEQ6jlpfpe9gn96Rvl08SLhwoRCr64SRQcxS8A=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-kVLTb5uCxmBkF+ZgBeFPazT1hOOehqWWX5Sr/hUeWOY=";
  };

  cmakeDir = "../api/cpp";

  nativeBuildInputs = [
    cmake
    corrosion
    cargo
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux patchelf;

  buildInputs = [
    fontconfig
    libGL
    libx11
    libxcursor
    libxi
    libxkbcommon
    wayland
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DSLINT_FEATURE_BACKEND_QT=OFF"
    "-DSLINT_FEATURE_INTERPRETER=OFF"
    "-DSLINT_FEATURE_LIVE_PREVIEW=OFF"
  ];

  # Corrosion forwards GNU Make's jobserver flags to Cargo. Slint's bundled
  # compiler builds jemalloc, whose generated Makefile rejects those flags.
  cmakeGenerator = "Ninja";

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath ${
      lib.makeLibraryPath [
        libGL
        libx11
        libxcursor
        libxi
        libxkbcommon
        wayland
      ]
    } $out/lib/libslint_cpp.so
  '';

  meta = {
    description = "Declarative GUI toolkit for C++ applications";
    homepage = "https://slint.dev";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
