{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  cmake,
  ninja,
  pkg-config,
  python3,
  makeWrapper,
  sdl3,
  zlib,
  libpng,
  freetype,
  sqlite,
  zstd,
  abseil-cpp,
  xxhash,
  fmt,
  nlohmann_json,
  cxxopts,
  curl,
  openssl,
  nghttp2,
  libGL,
  vulkan-loader,
}:

let
  version = "1.0.0";

  # Aurora normally downloads its dependencies with FetchContent.  The sandbox
  # has no network, so pin the prebuilt Dawn/nod releases it asks for and point
  # FetchContent at the unpacked trees.
  dawnVersion = "v20260807.225922";
  nodVersion = "v2.0.0-alpha.12";

  dawnPrebuilt = fetchzip {
    url = "https://github.com/encounter/dawn/releases/download/${dawnVersion}/dawn-linux-x86_64.tar.gz";
    hash = "sha256-deRtiZ221q6PO9zejJBwa56fCM63KEh6y2p7nM+MOYU=";
    stripRoot = false;
  };

  nodPrebuilt = fetchzip {
    url = "https://github.com/encounter/nod/releases/download/${nodVersion}/libnod-linux-x86_64.tar.gz";
    hash = "sha256-UepkfyagQmv2DGt4BOkl8g4xX+TxGNd0IXV93Xbmca4=";
    stripRoot = false;
  };

  # Sources for the dependencies Aurora/Borealis pull with FetchContent when a
  # suitable system package is not found.
  imgui = fetchzip {
    url = "https://github.com/ocornut/imgui/archive/refs/tags/v1.91.9b-docking.tar.gz";
    hash = "sha256-mQOJ6jCN+7VopgZ61yzaCnt4R1QLrW7+47xxMhFRHLQ=";
  };

  rmlui = fetchFromGitHub {
    owner = "encounter";
    repo = "RmlUi";
    rev = "f00a0fee38391b2f927114e11bea18dc0a7dba1e";
    hash = "sha256-pyTD/WXdmJmcCgqMjn11bYFHrEshZ4/SiJVOVGSs9M0=";
  };

  tracy = fetchzip {
    url = "https://github.com/wolfpld/tracy/archive/refs/tags/v0.14.1.zip";
    hash = "sha256-vcLI9jb7eYcR162LgBQ2P4A0oiZuYRfYRQiDhlAk5TI=";
  };

  curlSrc = fetchzip {
    url = "https://github.com/curl/curl/releases/download/curl-8_22_0/curl-8.22.0.tar.xz";
    hash = "sha256-3GBq7T5iU08VargRfd86qmAnheWRRd7ijH55PCw+ghY=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nookery";
  inherit version;

  src = fetchFromGitHub {
    owner = "flyngmt";
    repo = "Nookery";
    tag = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-BKUtN/pRBxakD9pFNQzhujJVt3kS6yd1Ng/n4Jur52E=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    makeWrapper
  ];

  buildInputs = [
    sdl3
    zlib
    libpng
    freetype
    sqlite
    zstd
    abseil-cpp
    xxhash
    fmt
    nlohmann_json
    cxxopts
    curl
    openssl
    nghttp2
    libGL
    vulkan-loader
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DBOREALIS_APP_VERSION_OVERRIDE=v${version}"
    "-DAURORA_SDL3_PROVIDER=system"
    "-DAURORA_DAWN_PROVIDER=package"
    "-DAURORA_NOD_PROVIDER=package"
    "-DFETCHCONTENT_SOURCE_DIR_DAWN_PREBUILT=${dawnPrebuilt}"
    "-DFETCHCONTENT_SOURCE_DIR_NOD_PREBUILT=${nodPrebuilt}"
    "-DFETCHCONTENT_SOURCE_DIR_IMGUI=${imgui}"
    "-DFETCHCONTENT_SOURCE_DIR_RMLUI=${rmlui}"
    "-DFETCHCONTENT_SOURCE_DIR_TRACY=${tracy}"
    "-DFETCHCONTENT_SOURCE_DIR_BOREALIS_CURL=${curlSrc}"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}/libexec/nookery"
  ];

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper $out/libexec/nookery/Nookery $out/bin/Nookery \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          vulkan-loader
        ]
      }

    install -Dm644 ${finalAttrs.src}/platforms/freedesktop/com.flyngmt.nookery.desktop \
      $out/share/applications/com.flyngmt.nookery.desktop
    for size in 16 32 48 64 128 256; do
      install -Dm644 ${finalAttrs.src}/platforms/freedesktop/''${size}x''${size}/apps/com.flyngmt.nookery.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/com.flyngmt.nookery.png
    done
  '';

  passthru.updateScript = ./update.py;

  meta = {
    description = "Native PC port of Animal Crossing for the GameCube";
    longDescription = ''
      Nookery is a native Windows/Linux/macOS/Android/iOS port of Animal
      Crossing (GameCube), built from the ac-decomp decompilation.  The
      repository contains no game assets; a legally obtained GAFE01 Rev 0
      disc image is required and is selected on first launch.
    '';
    homepage = "https://github.com/flyngmt/Nookery";
    license = with lib.licenses; [
      cc0
      mit
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "Nookery";
  };
})
