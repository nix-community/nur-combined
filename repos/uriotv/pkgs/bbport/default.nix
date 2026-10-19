{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  python3,
  perl,
  makeShellWrapper,
  wrapGAppsHook4,
  gobject-introspection,
  glslang,
  spirv-cross,
  spirv-tools,
  vulkan-headers,
  vulkan-loader,
  sdl3,
  ffmpeg-headless,
  boost,
  fmt,
  magic-enum,
  robin-map,
  xxhash,
  vulkan-memory-allocator,
  zydis,
  xbyak,
  spirv-headers,
  miniz,
  libx11,
  libxcb,
  xorgproto,
  wayland,
  protobuf,
  nlohmann_json,
  openssl,
  zlib,
  miniupnpc,
  gtk4,
  libadwaita,
  adwaita-icon-theme,
  librsvg,
  bash,
  coreutils,
  util-linux,
  procps,
  gawk,
  gnused,
  gnugrep,
  cacert,
  pkgsCross,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  version = "0.6";

  # FSR 4 v07 INT8 assets (MIT, built from AMD's FidelityFX SDK by Q2RTX), the same commit
  # tools/fetch_fsr4_assets.sh downloads from; bundled so FSR 4 works without network access.
  fsr4Assets = fetchFromGitHub {
    owner = "FireBurn";
    repo = "Q2RTX";
    rev = "ae8d628fae208813172446d1e49ed94150b04658";
    sparseCheckout = [ "baseq2/fsr4_shaders" ];
    hash = "sha256-3+ZuWBFxBxMfvlPPRJXpneZNAf2X1LD4e7xuTqjt0K8=";
  };

  # FSR 4.1.1 is extracted from the user's own AMD DLL by the launcher (tools/fsr4cap); its two
  # helper tools are prebuilt here, as in upstream's packaging/default.nix.
  dxilSpirv = stdenv.mkDerivation {
    pname = "dxil-spirv";
    version = "0-unstable-7dc5278";
    src = fetchFromGitHub {
      owner = "HansKristian-Work";
      repo = "dxil-spirv";
      rev = "7dc52786cdb1f53c54dd5c5c2698dff00ea5f0a3";
      fetchSubmodules = true;
      hash = "sha256-vdSMp6QusmVTGpcl9jr+wQUQy5HLWwjr/5TI8ARMWRI=";
    };
    patches = [ "${src'}/tools/fsr4cap/dxil-spirv-class-bindings.patch" ];
    nativeBuildInputs = [
      cmake
      ninja
      python3
    ];
  };

  fsr4capExe = stdenv.mkDerivation {
    pname = "fsr4cap.exe";
    inherit version;
    src = "${src'}/tools/fsr4cap";
    nativeBuildInputs = [ pkgsCross.mingwW64.buildPackages.gcc ];
    dontConfigure = true;
    buildPhase = ''
      x86_64-w64-mingw32-gcc -std=c11 -O1 -Wall -Iffx/api/include -Iffx/upscalers/include \
        fsr4cap.c capture.c rootsig.c -o fsr4cap.exe -ld3d12 -ldxguid -static
    '';
    installPhase = "install -Dm644 fsr4cap.exe $out";
  };

  src' = fetchFromGitHub {
    owner = "deadinside28";
    repo = "bloodborne_pc";
    tag = version;
    fetchSubmodules = true;
    hash = "sha256-yyhLJhWbBgV6ftaOECkPOJSInI3pqj16bglmf4KPDRE=";
  };

  runtimePath = lib.makeBinPath [
    bash
    coreutils
    util-linux
    procps
    gawk
    gnused
    gnugrep
    spirv-tools
  ];
in
stdenv.mkDerivation {
  pname = "bbport";
  inherit version;
  src = src';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    perl
    glslang
    spirv-cross
    makeShellWrapper
    wrapGAppsHook4
    gobject-introspection
    copyDesktopItems
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
    sdl3
    ffmpeg-headless
    boost
    fmt
    magic-enum
    robin-map
    xxhash
    vulkan-memory-allocator
    zydis
    xbyak
    spirv-headers
    miniz
    libx11
    libxcb
    xorgproto
    wayland
    # Online module (gpu/bbnet): shadNet client, HTTPS, UPnP
    protobuf
    nlohmann_json
    openssl
    zlib
    miniupnpc
    # Launcher
    gtk4
    libadwaita
    adwaita-icon-theme
    librsvg
  ];

  postPatch = ''
    # The port's changes to FSR-Vulkan (build.sh applies them with git apply).
    for p in gpu/patches/fsr-vulkan/*.patch; do
      patch -d gpu/third_party/fsr-vulkan -p1 < "$p"
    done
    patchShebangs tools scripts launcher
  '';

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  # Mirrors build.sh without its PGO/DLSS branches and without the build-tree RUNPATH.
  buildPhase = ''
    runHook preBuild

    cmake -S gpu -B out/gpu -G Ninja \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_SKIP_BUILD_RPATH=OFF \
      -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
      -DCMAKE_INSTALL_RPATH='$ORIGIN' \
      -DBB_PGO=off -DBB_LTO=ON
    ninja -C out/gpu -j$NIX_BUILD_CORES bbgpu bbnet

    read -r -a includes <<< "$(pkg-config --cflags vulkan sdl3)"
    read -r -a libraries <<< "$(pkg-config --libs vulkan sdl3)"

    mkdir -p out/atrac9
    for f in third_party/LibAtrac9/C/src/*.c; do
      $CC -std=c99 -O2 -g -w -c "$f" -o "out/atrac9/$(basename "''${f%.c}").o"
    done
    $AR rcs out/libatrac9.a out/atrac9/*.o

    $CC -std=c11 -O2 -g -Wall -Wextra -Werror -pthread -no-pie "''${includes[@]}" -I. -Isrc \
      src/probe.c src/runtime*.c src/vulkan_smoke.c out/libatrac9.a -lm \
      -Lout/gpu -lbbgpu -Wl,-rpath,'$ORIGIN/gpu' -rdynamic \
      "''${libraries[@]}" -o out/bb-probe
    $CC -std=c11 -O2 -Wall -Wextra -Werror "''${includes[@]}" tools/gpu_capabilities.c \
      "''${libraries[@]}" -o out/bb-gpu-capabilities

    # FSR 4 assets and their faster, bit-exact rewritten passes (fsr4_shaders/opt).
    cp -r ${fsr4Assets}/baseq2/fsr4_shaders fsr4_shaders
    chmod -R u+w fsr4_shaders
    bash tools/fsr4_optimize.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    d=$out/share/bbport
    mkdir -p $d/bin/gpu $d/tools $out/bin
    cp run.sh $d/
    cp -r scripts patches fsr4_shaders launcher $d/
    cp -r tools/fsr4cap $d/tools/
    mkdir -p $d/tools/fsr4cap/bin
    ln -s ${dxilSpirv}/bin/dxil-spirv $d/tools/fsr4cap/bin/dxil-spirv
    install -m644 ${fsr4capExe} $d/tools/fsr4cap/bin/fsr4cap.exe

    install -m755 out/bb-probe out/bb-gpu-capabilities $d/bin/
    install -m755 out/gpu/libbbgpu.so out/gpu/libbbnet.so $d/bin/gpu/

    install -Dm644 LICENSE $out/share/licenses/bbport/LICENSE

    runHook postInstall
  '';

  # patchelf corrupts the non-PIE bb-probe's symbol versions (upstream packaging/default.nix);
  # all binaries already carry the RUNPATHs they need.
  dontPatchELF = true;
  # Their debug info names the build's headers and compiler (~1 GiB of closure); symbols stay.
  stripDebugList = [ "share/bbport/bin" ];
  dontWrapGApps = true;

  postFixup = ''
    d=$out/share/bbport
    common=(
      --set BB_PREBUILT 1
      --set PYTHON ${python3}/bin/python3
      --prefix PATH : ${runtimePath}
      --run '[ -r "''${SSL_CERT_FILE:-}" ] || export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt'
      --run 'export BB_DATA_DIR=''${BB_DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/bbport}; mkdir -p "$BB_DATA_DIR"'
    )
    # GTK4 launcher: pick the game folder, settings, start.
    makeShellWrapper ${python3.withPackages (ps: [ ps.pygobject3 ])}/bin/python3 $out/bin/bbport \
      "''${gappsWrapperArgs[@]}" "''${common[@]}" \
      --add-flags $d/launcher/bbport_launcher.py
    # The game alone, without the launcher (settings from $BB_DATA_DIR/bbport.ini).
    makeShellWrapper ${bash}/bin/bash $out/bin/bbport-game "''${common[@]}" \
      --add-flags $d/run.sh
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "io.github.bbport.Launcher";
      desktopName = "Bloodborne";
      genericName = "Bloodborne launcher";
      comment = "Native Bloodborne port launcher";
      exec = "bbport";
      icon = "applications-games";
      categories = [ "Game" ];
      keywords = [
        "bbport"
        "Bloodborne"
        "PS4"
      ];
      # The launcher's GTK application id, so its window groups with this entry.
      startupWMClass = "io.github.bbport.Launcher";
      actions.play = {
        name = "Play without the launcher";
        # The game with the saved settings, no launcher window.
        exec = "bbport --play";
      };
    })
  ];

  meta = with lib; {
    description = "Native Linux port of Bloodborne (PS4, v1.09); requires your own game dump";
    homepage = "https://github.com/deadinside28/bloodborne_pc";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "bbport";
  };
}
