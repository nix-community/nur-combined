{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  cmake,
  ninja,
  pkg-config,
  python3,
  git,
  vulkan-loader,
  libGL,
  libglvnd,
  alsa-lib,
  libpulseaudio,
  pipewire,
  dbus,
  systemd,
  libgcc,
  patchelf,
  libX11,
  libxcb,
  libXcursor,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXScrnSaver,
  libXtst,
  libxkbcommon,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libdecor,
  libffi,
  writeShellApplication,
  nix,
}:

let
  version = "0.1.5-unstable-2026-11-20";

  src = fetchFromGitHub {
    owner = "boykopovar";
    repo = "AnyPS5";
    rev = "5b6fb5480c18098f50d5a5cf1c04161bc1eb568d";
    hash = "sha256-Kzr7sia/8ANsYRdm/9/IoH/0ZIyu4cH086RcZNjrDho=";
  };

  # Submodules, pinned by the superproject. The build reads each one straight
  # out of 3rdparty/<name>, so they are copied into the source tree.
  libAtrac9 = fetchFromGitHub {
    owner = "shadps4-emu";
    repo = "ext-LibAtrac9";
    rev = "946e05a9212976626a9f5e52f29c0a7202871f29";
    hash = "sha256-YggYGOZVxu+32Dn1BM4sQt7gBDdjfHp+sRbwoILm7zc=";
  };

  sdl2 = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL";
    rev = "74be4c2836da0940f0144d0d97852606f9ab11e9";
    hash = "sha256-vYnFeWK9xhEtOvuCSy5f02KPRMJD8Qn3KYXzBSi1oao=";
  };

  spirvHeaders = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "b824a462d4256d720bebb40e78b9eb8f78bbb305";
    hash = "sha256-HjJjMuqTrYv5LUOWcexzPHb8nhOT4duooDAhDsd44Zo=";
  };

  spirvTools = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Tools";
    rev = "262bdab48146c937467f826699a40da0fdfc0f1a";
    hash = "sha256-H+t7ZH4SB+XgWTLj9XaJWZwAWk8M2QeC98Zi5ay8PBc=";
  };

  vulkanHeaders = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Headers";
    rev = "2fa203425eb4af9dfc6b03f97ef72b0b5bcb8350";
    hash = "sha256-DIePLzDoImnaso0WYUv819wSDeA7Zy1I/tYAbsALXKg=";
  };

  vulkanMemoryAllocator = fetchFromGitHub {
    owner = "GPUOpen-LibrariesAndSDKs";
    repo = "VulkanMemoryAllocator";
    rev = "a1d434708c217b2a6c7b365f1fe41fa03a562e59";
    hash = "sha256-P8JM7sKQbspTMK4KINa/M52sVnVO4w7L+ZKRPKfVRGw=";
  };

  zarchive = fetchFromGitHub {
    owner = "Exzap";
    repo = "ZArchive";
    rev = "965b66c8d67b6b7e30fd63b3b75aa91a99ff303b";
    hash = "sha256-OYYVo2R0eJwLHOKzRrri69V8exRvtqA6AgPgXL/6b2I=";
  };

  cairo = fetchzip {
    url = "https://gitlab.freedesktop.org/cairo/cairo/-/archive/3909090108bb2db55330e3eb148aebe664735363/cairo-3909090108bb2db55330e3eb148aebe664735363.tar.gz";
    hash = "sha256-EN5TW31j/nRjcJXTI+QzCszFZNJVvYCe8qUji+aW/zQ=";
  };

  curl = fetchFromGitHub {
    owner = "curl";
    repo = "curl";
    rev = "801bd5138ce31aa0d906fa4e2eabfc599d74e793";
    hash = "sha256-4w15NHw3D+YBuK02ZIZqvGaWgyQVc61MZ34pkLu0Oug=";
  };

  ffmpegCore = fetchFromGitHub {
    owner = "KytyPS5";
    repo = "ext-ffmpeg-core";
    rev = "9ac4cfd195f192ed8b08566f49c28dbb48d08341";
    hash = "sha256-Fj15Xz26Jiw9B/oD72do22TNdLz+jmy0ZTT8lkWgQDA=";
  };

  fontconfig = fetchFromGitHub {
    owner = "fontconfig";
    repo = "fontconfig";
    rev = "72b9a48f57de6204d99ce1c217b5609ee92ece9b";
    hash = "sha256-XWQf5+c6qW8IURQBSCKkOaGiLxbnhwrWthHWBNvfTV8=";
  };

  freetype = fetchFromGitHub {
    owner = "freetype";
    repo = "freetype";
    rev = "37515cf56ba3349656049edbed89ffc6f6466f2d";
    hash = "sha256-Mcmb67mYYs6c8yQv39iIq5gxUGBZmWQXkMGSOw6jt14=";
  };

  glslang = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "glslang";
    rev = "ba1640446f3826a518721d1f083f3a8cca1120c3";
    hash = "sha256-xplVnLcfVTg/iUScla8TAdHzvI/jq+cjLUSRgKNBKDI=";
  };

  harfbuzz = fetchFromGitHub {
    owner = "harfbuzz";
    repo = "harfbuzz";
    rev = "a1d9bfe62818ef0fa9cf63b6e6d51436b1c93cbc";
    hash = "sha256-LQUMplPgV8J8RQJAv83udrBgBbk6OWHRTbtvFrNcUfM=";
  };

  icu = fetchFromGitHub {
    owner = "unicode-org";
    repo = "icu";
    rev = "049e0d6a420629ac7db77256987d083a563287b5";
    hash = "sha256-FkLEVWWSxYYw7irbkXO7HlUJ5hRsrVLmy/EpgbZ5X2s=";
  };

  jxrlib = fetchFromGitHub {
    owner = "4creators";
    repo = "jxrlib";
    rev = "f7521879862b9085318e814c6157490dd9dbbdb4";
    hash = "sha256-vBjJUqXZDs6vsiZkZfjBfjxH89dh4uXW44BbAOCCY2Y=";
  };

  libfvad = fetchFromGitHub {
    owner = "dpirch";
    repo = "libfvad";
    rev = "532ab666c20d3cfda38bca63abbb0f152706c369";
    hash = "sha256-TS/2ywq88AAPJEfYD5b0H7tzpAoigynsctzZodvPFzU=";
  };

  libjpegTurbo = fetchFromGitHub {
    owner = "libjpeg-turbo";
    repo = "libjpeg-turbo";
    rev = "c85e6b905bf237038faa936dab160ebfc5da0344";
    hash = "sha256-SPxWCDt9hFQ8uRaaKLkpWp9oPhfcRkDBm5MarTgdmV4=";
  };

  libpng = fetchFromGitHub {
    owner = "pnggroup";
    repo = "libpng";
    rev = "cd952f49f95bb27154ae77dbb103032d95f6e580";
    hash = "sha256-3+wFnGvQxPbK5DepBu0EWqnjEy1UBOUtEsq6+jphHKk=";
  };

  libpsl = fetchFromGitHub {
    owner = "rockdaboot";
    repo = "libpsl";
    rev = "ba4c49a205408845834b1648ad23c15ee09f722b";
    hash = "sha256-G0PXMkBccS5j6y+AxCtbpevlz3oy3dylG/VcZJ0z3lM=";
  };

  # libpsl's build downloads this list; its source tree does not contain it.
  # Rendered from a pinned commit because the live file changes daily.
  publicSuffixList = fetchurl {
    url = "https://raw.githubusercontent.com/publicsuffix/list/09c1b150f33c6145a73afcf7db0fb872fc54b4d1/public_suffix_list.dat";
    hash = "sha256-DLrm2+nxpsQjH3cZQCgX00W/OaS9/wiUIx6aLL7DDY0=";
  };

  libresslOpenbsd = fetchFromGitHub {
    owner = "libressl";
    repo = "openbsd";
    rev = "078b3d1df8ca2011c1605cd40418c58fa0f5b143";
    hash = "sha256-i2bMe918cdGdeTgD3mS0nGGtHrMgh08AM1j4NibLnyQ=";
  };

  libusbCmake = fetchFromGitHub {
    owner = "libusb";
    repo = "libusb-cmake";
    rev = "bea6567b63796ab27c1c33257d230284fb2d8316";
    hash = "sha256-cXbZdtKUar+7SIYbnCUn1TZeg2cNsiw4WWHNUYe4vtI=";
  };

  libwpe = fetchFromGitHub {
    owner = "WebPlatformForEmbedded";
    repo = "libwpe";
    rev = "b90a8396864c9824a43838a5879f6ab01420c69e";
    hash = "sha256-cWdu52xs/VJzTEAeEXgVVGbZKRflbPjPgBcZJmbBhgk=";
  };

  libxml2 = fetchFromGitHub {
    owner = "GNOME";
    repo = "libxml2";
    rev = "7846b0a677f8d3ce72486125fa281e92ac9970e8";
    hash = "sha256-ctkcy5+EMBzZmuwxn2AIDqmAQV/TczFdE3fg1zBLWRo=";
  };

  mbedtls = fetchFromGitHub {
    owner = "Mbed-TLS";
    repo = "mbedtls";
    rev = "068ff080b369adfac81509f9b57b2afabaf82dc5";
    hash = "sha256-gTl1U6tPHTEl8JrKNPbggvkNzXRJqjk14QtIdvpfDV8=";
  };

  mbedtlsFramework = fetchFromGitHub {
    owner = "Mbed-TLS";
    repo = "mbedtls-framework";
    rev = "dde0c4a0e448a0552f18817dcea633bb851fd288";
    hash = "sha256-gHaPbnu2HXnSk52DR438mFt4kCb8MAsHebbNKTflwXQ=";
  };

  mimalloc = fetchFromGitHub {
    owner = "microsoft";
    repo = "mimalloc";
    rev = "f8401befa675adb13b98decababd7fdc59572477";
    hash = "sha256-xAxqcJ92qdJtOvB9JghkIQ3HJ9InjZt+IZvJ6W99r0k=";
  };

  nghttp2 = fetchFromGitHub {
    owner = "nghttp2";
    repo = "nghttp2";
    rev = "85e300c79fb6dbcfa9c1013215c8710c1c2cd3d2";
    hash = "sha256-YoQ0hYyQGgfh75rEVaJPrFb4Gxc8Vs+ZuAbhBbkNg6k=";
  };

  ogg = fetchFromGitHub {
    owner = "xiph";
    repo = "ogg";
    rev = "be05b13e98b048f0b5a0f5fa8ce514d56db5f822";
    hash = "sha256-YsPtRva7fGaG7/VXNmzYGlPhbbMoLcGru9Bl8caE7Ao=";
  };

  opus = fetchFromGitHub {
    owner = "xiph";
    repo = "opus";
    rev = "22244de5a79bd1d6d623c32e72bf1954b56235be";
    hash = "sha256-I1f+J//ZJBMj88+PQhsYBjz3fm4Ll3ckZD+fYa6/3Y0=";
  };

  pixman = fetchzip {
    url = "https://gitlab.freedesktop.org/pixman/pixman/-/archive/37216a32839f59e8dcaa4c3951b3fcfc3f07852c/pixman-37216a32839f59e8dcaa4c3951b3fcfc3f07852c.tar.gz";
    hash = "sha256-2vvsf9DOg6i0ZAHl6kp0rsfgM2nUQ3x9vbPg4xPIaWQ=";
  };

  quickjs = fetchFromGitHub {
    owner = "quickjs-ng";
    repo = "quickjs";
    rev = "6d46d07d04041b40f4f49eaa7fdebe44c314c699";
    hash = "sha256-TmKpLIrGeTSYk77hfuIQtxT/k9cxUo30bICqFumgDrY=";
  };

  sqlite = fetchFromGitHub {
    owner = "sqlite";
    repo = "sqlite";
    rev = "57520227c95396ce39ba6ecaac8d475b78dd3964";
    hash = "sha256-IeREZ1eC7OdaFq0ZtbBCG2Habn5Ak1wEHW0shTmLvHc=";
  };

  stb = fetchFromGitHub {
    owner = "nothings";
    repo = "stb";
    rev = "2c980bb59875b0d32144a71867fbdebb2f77cd20";
    hash = "sha256-vA5RZLte4gf5/NkbWT3VNzGVD04kyVTHPeEZwxNnxi0=";
  };

  tracy = fetchFromGitHub {
    owner = "wolfpld";
    repo = "tracy";
    rev = "30997d5ca6bb632cc10807a1da8a6d3de0aeeb3c";
    hash = "sha256-vcLI9jb7eYcR162LgBQ2P4A0oiZuYRfYRQiDhlAk5TI=";
  };

  vgmstream = fetchFromGitHub {
    owner = "vgmstream";
    repo = "vgmstream";
    rev = "7c520e8f9b078dfde2f84f1b5bcbad0c6c415806";
    hash = "sha256-bolJp1PiAazWQbEZU2Ffl7olh00Hd88+u8XHG9sSL40=";
  };

  vorbis = fetchFromGitHub {
    owner = "xiph";
    repo = "vorbis";
    rev = "c2aa86b05e981c96bf381fc6aa11cdd03eccc2fb";
    hash = "sha256-3vIER0GvVUAk+ZqwLoMIpoCoE0O/JOi97hekWwK8HN0=";
  };

  zlib = fetchFromGitHub {
    owner = "madler";
    repo = "zlib";
    rev = "da607da739fa6047df13e66a2af6b8bec7c2a498";
    hash = "sha256-Sthd9RsydSLaITNlBp6g1X35WKZdS4h7gr0QhRqdGoI=";
  };

  zstd = fetchFromGitHub {
    owner = "facebook";
    repo = "zstd";
    rev = "f8745da6ff1ad1e7bab384bd1f9d742439278e99";
    hash = "sha256-tNFWIT9ydfozB8dWcmTMuZLCQmQudTFJIkSr0aG7S44=";
  };

  ffmpegPrebuilt = fetchzip {
    url = "https://github.com/KytyPS5/ext-ffmpeg-core/releases/download/9ac4cfd195f1/ffmpeg-linux-x64.zip";
    hash = "sha256-MX8Rifr6CvFFkm0IAmJPNGzLb8FG5HJJUKO/l0zegko=";
    stripRoot = false;
  };
in
stdenv.mkDerivation {
  pname = "anyps5";
  inherit version src;

  postPatch = ''
    # The static glibc link makes CMake's Threads probe fail in the sandbox.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(CMAKE_EXE_LINKER_FLAGS "''${CMAKE_EXE_LINKER_FLAGS} -static -static-libgcc -static-libstdc++")' \
                     'set(CMAKE_EXE_LINKER_FLAGS "''${CMAKE_EXE_LINKER_FLAGS}")'
  ''
  # The full emulator build is Linux-only. The relinker itself (built with
  # ANYPS5_RELINKER_ONLY) has no third-party dependencies, so macOS only needs
  # the main source tree.
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    cp -rT ${libAtrac9} 3rdparty/LibAtrac9
    cp -rT ${sdl2} 3rdparty/SDL2
    cp -rT ${spirvHeaders} 3rdparty/SPIRV-Headers
    cp -rT ${spirvTools} 3rdparty/SPIRV-Tools
    cp -rT ${vulkanHeaders} 3rdparty/Vulkan-Headers
    cp -rT ${vulkanMemoryAllocator} 3rdparty/VulkanMemoryAllocator
    cp -rT ${zarchive} 3rdparty/ZArchive
    cp -rT ${cairo} 3rdparty/cairo
    cp -rT ${curl} 3rdparty/curl
    cp -rT ${ffmpegCore} 3rdparty/ffmpeg-core
    cp -rT ${fontconfig} 3rdparty/fontconfig
    cp -rT ${freetype} 3rdparty/freetype
    cp -rT ${glslang} 3rdparty/glslang
    cp -rT ${harfbuzz} 3rdparty/harfbuzz
    cp -rT ${icu} 3rdparty/icu
    cp -rT ${jxrlib} 3rdparty/jxrlib
    cp -rT ${libfvad} 3rdparty/libfvad
    cp -rT ${libjpegTurbo} 3rdparty/libjpeg-turbo
    cp -rT ${libpng} 3rdparty/libpng
    cp -rT ${libpsl} 3rdparty/libpsl
    chmod -R u+w 3rdparty/libpsl
    mkdir -p 3rdparty/libpsl/list
    cp ${publicSuffixList} 3rdparty/libpsl/list/public_suffix_list.dat
    cp -rT ${libresslOpenbsd} 3rdparty/libressl-openbsd
    cp -rT ${libusbCmake} 3rdparty/libusb-cmake
    cp -rT ${libwpe} 3rdparty/libwpe
    cp -rT ${libxml2} 3rdparty/libxml2
    cp -rT ${mbedtls} 3rdparty/mbedtls
    chmod -R u+w 3rdparty/mbedtls
    cp -rT ${mbedtlsFramework} 3rdparty/mbedtls/framework
    cp -rT ${mimalloc} 3rdparty/mimalloc
    cp -rT ${nghttp2} 3rdparty/nghttp2
    cp -rT ${ogg} 3rdparty/ogg
    cp -rT ${opus} 3rdparty/opus
    cp -rT ${pixman} 3rdparty/pixman
    cp -rT ${quickjs} 3rdparty/quickjs
    cp -rT ${sqlite} 3rdparty/sqlite
    cp -rT ${stb} 3rdparty/stb
    cp -rT ${tracy} 3rdparty/tracy
    cp -rT ${vgmstream} 3rdparty/vgmstream
    cp -rT ${vorbis} 3rdparty/vorbis
    cp -rT ${zlib} 3rdparty/zlib
    cp -rT ${zstd} 3rdparty/zstd
    chmod -R u+w 3rdparty
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    git
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland-scanner
    patchelf
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    vulkan-loader
    libGL
    libglvnd
    alsa-lib
    libpulseaudio
    pipewire
    dbus
    systemd
    libX11
    libxcb
    libXcursor
    libXext
    libXfixes
    libXi
    libXrandr
    libXScrnSaver
    libXtst
    libxkbcommon
    wayland
    wayland-protocols
    libdecor
    libffi
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_TESTING=OFF"
    "-DANYPS5_USE_SYSTEM_DEPS=OFF"
    "-DPython3_EXECUTABLE=${python3}/bin/python3"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "-DFFMPEG_PREBUILT_DIR=${ffmpegPrebuilt}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-DANYPS5_RELINKER_ONLY=ON"
  ];

  # Core libraries are EXCLUDE_FROM_ALL; the documented build runs the libs target.
  # macOS builds only the dependency-free relinker.
  postBuild = lib.optionalString stdenv.hostPlatform.isLinux ''
    cmake --build . --target libs --parallel $NIX_BUILD_CORES
  '';

  # The .prx libraries link each other by name and are meant to be found next to
  # one another, so their RPATH has to keep $ORIGIN instead of absolute paths.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    runtime_path="${
      lib.makeLibraryPath [
        stdenv.cc.cc.lib
        libgcc.lib
      ]
    }"
    for lib in $out/lib/anyps5/libs/*.prx $out/lib/anyps5/libs/*.so*; do
      if [ -e "$lib" ]; then
        patchelf --set-rpath "\$ORIGIN:$runtime_path" "$lib"
      fi
    done
    patchelf --set-rpath "$runtime_path" $out/bin/relinker
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 core/relinker/relinker $out/bin/relinker

  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/lib/anyps5/libs
    cp -a core/libs/libs/*.prx $out/lib/anyps5/libs/
    if ls core/libs/libs/libmimalloc.so* >/dev/null 2>&1; then
      cp -a core/libs/libs/libmimalloc.so* $out/lib/anyps5/libs/
    fi
  ''
  + ''

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool for automatic PS5 executables porting to Linux and Windows";
    homepage = "https://github.com/boykopovar/AnyPS5";
    downloadPage = "https://github.com/boykopovar/AnyPS5/releases";
    license = licenses.gpl2Only;
    mainProgram = "relinker";
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };

  passthru.updateScript = writeShellApplication {
    name = "update-anyps5";
    runtimeInputs = [
      python3
      git
      nix
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="anyps5"
      exec ${python3}/bin/python3 ${./update.py} "$@"
    '';
  };
}
