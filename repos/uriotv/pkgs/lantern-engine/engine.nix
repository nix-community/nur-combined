{ lib, stdenv, cmake, ninja, pkg-config, python3, glslang, spirv-cross, spirv-tools,
  vulkan-headers, vulkan-loader, sdl3, ffmpeg-headless, boost, fmt, magic-enum,
  robin-map, xxhash, vulkan-memory-allocator, zydis, xbyak, spirv-headers, miniz,
  libx11, libxcb, xorgproto, wayland, protobuf, nlohmann_json, openssl, zlib,
  miniupnpc, src, version }:
stdenv.mkDerivation {
  pname = "lantern-engine-core";
  inherit src version;
  postUnpack = ''sourceRoot="$sourceRoot/engine"'';
  nativeBuildInputs = [ cmake ninja pkg-config python3 glslang spirv-cross spirv-tools ];
  buildInputs = [ vulkan-headers vulkan-loader sdl3 ffmpeg-headless boost fmt magic-enum
    robin-map xxhash vulkan-memory-allocator zydis xbyak spirv-headers miniz
    libx11 libxcb xorgproto wayland protobuf nlohmann_json openssl zlib miniupnpc ];
  # Upstream v0.9.37 repeats this designated initializer (and puts the first
  # occurrence before physicalDevice); GCC correctly rejects it.
  patches = [ ./vma-initializer.patch ];
  postPatch = ''
    substituteInPlace gpu/shadps4/video_core/renderer_vulkan/vk_swapchain.cpp \
      --replace-fail 'hdr_format = {};' 'hdr_format = vk::SurfaceFormatKHR{};'
    substituteInPlace gpu/CMakeLists.txt \
      --replace-fail '${"$"}{CMAKE_CURRENT_SOURCE_DIR}/third_party/fonts/' "$out/fonts/" \
      --replace-fail '${"$"}{CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/misc/fonts/' "$out/fonts/"
  '';
  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  buildPhase = ''
    runHook preBuild
    mkdir -p $out/fonts
    cp gpu/third_party/fonts/*.ttf gpu/third_party/imgui/misc/fonts/Roboto-Medium.ttf $out/fonts/
    cmake -S gpu -B out/gpu -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DBB_PGO=off -DBB_LTO=OFF -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
      -DCMAKE_INSTALL_RPATH='$ORIGIN;$ORIGIN/gpu'
    ninja -C out/gpu -j$NIX_BUILD_CORES bbgpu bb-engine-assets bb-shader-lab
    cp out/gpu/bb-engine-assets out/gpu/bb-shader-lab out/
    read -r -a includes <<< "$(pkg-config --cflags vulkan sdl3)"
    read -r -a libraries <<< "$(pkg-config --libs vulkan sdl3)"
    mkdir -p out/atrac9
    for f in third_party/LibAtrac9/C/src/*.c; do
      $CC -std=c99 -O2 -w -c "$f" -o "out/atrac9/$(basename "''${f%.c}").o"
    done
    $AR rcs out/libatrac9.a out/atrac9/*.o
    $CC -std=gnu11 -O2 -Wall -Wextra -pthread -no-pie "''${includes[@]}" -I. -Isrc \
      src/probe.c src/runtime*.c src/vulkan_smoke.c out/libatrac9.a -lm \
      -Lout/gpu -lbbgpu -Wl,-rpath,'$ORIGIN/gpu' -rdynamic "''${libraries[@]}" -o out/bb-probe
    $CC -std=gnu11 -O2 -Wall -Wextra "''${includes[@]}" tools/gpu_capabilities.c \
      "''${libraries[@]}" -o out/bb-gpu-capabilities
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/out/gpu
    cp -r scripts patches data licenses $out/
    cp run.sh $out/
    cp ../LICENSE ../NOTICE $out/licenses/
    mkdir -p $out/fonts
    cp gpu/third_party/fonts/*.ttf gpu/third_party/imgui/misc/fonts/Roboto-Medium.ttf $out/fonts/
    # A conservative identity invalidates shader caches when this engine changes.
    basename "$out" > $out/out/gpu-cache.id
    cp out/bb-probe out/bb-gpu-capabilities out/bb-engine-assets out/bb-shader-lab $out/out/
    cp out/gpu/libbbgpu.so $out/out/gpu/
    # Defaults are supplied by the launcher when a key is absent.
    touch $out/lantern.default.ini
    install -m755 packaging/linux/bb-start $out/out/bb-start
    runHook postInstall
  '';
  dontPatchELF = true;
  stripDebugList = [ "out" ];
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    for program in bb-probe bb-gpu-capabilities bb-engine-assets bb-shader-lab; do
      if ldd "$out/out/$program" | grep 'not found'; then
        echo "Unresolved runtime dependencies in $program" >&2
        exit 1
      fi
    done
    runHook postInstallCheck
  '';
  meta.platforms = [ "x86_64-linux" ];
}
