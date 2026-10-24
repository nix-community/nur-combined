{
  lib,
  callPackage,
  clang,
  gn,
  python3,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libglvnd,
  mesa,
  fontconfig,
  freetype,
  harfbuzz,
  systemd,
  icu,
  expat,
  libpng,
  libjpeg,
  zlib,
  libwebp,
  libtiff,
  libheif,
  libjxl,
  libxkbcommon,
  fetchFromGitHub,
}:

let
  # Pinned by cutefish-toolkit/scripts/fetch-skia.sh. Official Skia builds link
  # the system FreeType, HarfBuzz, ICU and image codecs instead of third_party/externals.
  skiaSrc = fetchFromGitHub {
    owner = "google";
    repo = "skia";
    rev = "95ee33d7ec7791ab9c071675710a14fe6408ae4f";
    hash = "sha256-ou4cLjDBhKrL7yUJX/4el/HTDDWcmpL9ZGsdmHjX3I4=";
  };
in
(callPackage ../cutefish/mk.nix { }) {
  pname = "cutefish-toolkit";

  patches = [ ../cutefish/patches/toolkit-xdg-paths.patch ];

  postPatch = ''
        substituteInPlace cmake/Skia.cmake \
          --replace-fail 'find_program(SKIA_GN gn PATHS ''${SKIA_SOURCE_DIR}/bin NO_DEFAULT_PATH REQUIRED)' \
            'find_program(SKIA_GN gn REQUIRED)' \
          --replace-fail 'skia_enable_fontmgr_custom_empty = false' \
            'skia_enable_fontmgr_custom_empty = false
    skia_system_freetype2_include_path = \"${lib.getDev freetype}/include/freetype2\"'
        substituteInPlace CMakeLists.txt \
          --replace-fail 'add_subdirectory(examples)' '# add_subdirectory(examples)'
  '';

  preConfigure = ''
    mkdir -p third_party
    cp -a ${skiaSrc}/. third_party/skia
    chmod -R u+w third_party/skia
    substituteInPlace third_party/skia/third_party/harfbuzz/BUILD.gn \
      --replace-fail '/usr/include/harfbuzz' '${lib.getDev harfbuzz}/include/harfbuzz'
  '';

  extraNativeBuildInputs = [
    clang
    gn
    python3
    wayland-scanner
  ];

  extraBuildInputs = [
    wayland
    wayland-protocols
    libglvnd
    mesa
    fontconfig
    freetype
    harfbuzz
    systemd
    icu
    expat
    libpng
    libjpeg
    zlib
    libwebp
    libtiff
    libheif
    libjxl
    libxkbcommon
  ];

  # libjxl is dlopened by SONAME, so the dynamic linker has to find it on the toolkit's rpath.
  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath [ libjxl ]} "$out/lib/libcutefish-toolkit.so"
  '';

  meta = {
    description = "Wayland client toolkit for the Cutefish desktop, drawn with Skia";
  };
}
