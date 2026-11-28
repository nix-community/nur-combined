{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  ninja,
  pkg-config,
  python3,
  llvmPackages,
  unshield,
  sdl3,
  vulkan-headers,
  vulkan-loader,
  alsa-lib,
  dbus,
  libdrm,
  libgbm,
  libGL,
  libjack2,
  libpulseaudio,
  libusb1,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxscrnsaver,
  libx11,
  libxcb,
  libxtst,
  libdecor,
  libayatana-appindicator,
  pipewire,
  systemdLibs,
  wayland,
  wayland-scanner,
  wayland-protocols,
  patchelf,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  version = "0.9.0";

  # The recompiler and runtime live in a checkout beside the port
  # (WINRECOMP_DIR); winrecomp has no release tags, so this follows the
  # revision used with this port revision.
  toolkit = import ./toolkit.nix { inherit fetchFromGitHub; };

  python = python3.withPackages (ps: [
    ps.capstone
    ps.pefile
  ]);

  clang = llvmPackages.clang;

  # launcher/CMakeLists.txt downloads this at configure time when it is
  # absent.  Put the pinned copy in the build directory before configuring.
  stbTruetype = fetchurl {
    name = "stb_truetype.h";
    url = "https://raw.githubusercontent.com/nothings/stb/2c980bb59875b0d32144a71867fbdebb2f77cd20/stb_truetype.h";
    hash = "sha256-7NMLBeDdT+o6E8JoEN2eGZLcN5BJSCw5PVoZ5rUJCqs=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "grand-theft-auto-2-recompiled";
  inherit version;

  src = fetchFromGitHub {
    owner = "almost-drowned-rat";
    repo = "Grand-Theft-Auto-2-Recompiled";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HyDlI/jj5HXf7vK96hPtnGBd9Y/6RO4ujEu+F3XKlsI=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    wayland-scanner
    patchelf
    copyDesktopItems
  ];

  buildInputs = [
    sdl3
    vulkan-headers
    vulkan-loader
    alsa-lib
    dbus
    libdrm
    libgbm
    libGL
    libjack2
    libpulseaudio
    libusb1
    libxcursor
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxscrnsaver
    libx11
    libxcb
    libxtst
    libdecor
    libayatana-appindicator
    pipewire
    systemdLibs
    wayland
    wayland-protocols
  ];

  dontConfigure = true;
  # The launcher carries its payload after the ELF.  Fixup's strip/patchelf
  # would truncate it, so do both before appending the payload instead.
  dontStrip = true;
  dontPatchELF = true;

  buildPhase = ''
    runHook preBuild

    # The port and the runtime are shipped as static libraries.  The game's
    # generated C is compiled from the player's GTA2.exe on first start.
    cmake -S . -B build-port -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DWINRECOMP_DIR=${toolkit} \
      -DGTA2_PORT_ONLY=ON \
      -DSDL3_DIR=${sdl3.dev}/lib/cmake/SDL3 \
      -DWR_VULKAN_INCLUDE_DIR=${vulkan-headers}/include
    cmake --build build-port

    # Upstream links the setup launcher against its own static SDL3 build.
    mkdir -p build-launcher/launcher_generated
    install -m644 ${stbTruetype} build-launcher/launcher_generated/stb_truetype.h
    cmake -S launcher -B build-launcher -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DGTA2_LAUNCHER_SDL3=${sdl3.src} \
      -DGTA2_LAUNCHER_ICON=$PWD/assets/icon_64.bmp \
      -DGTA2_LAUNCHER_OUTPUT=gta2-launcher \
      -DSDL_SNDIO=OFF \
      -DSDL_IBUS=OFF
    cmake --build build-launcher --target gta2_launcher

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/libexec" "$out/share/icons/hicolor/256x256/apps"
    install -m755 build-launcher/gta2-launcher "$out/libexec/gta2-launcher"
    patchelf --shrink-rpath "$out/libexec/gta2-launcher"
    ${stdenv.cc.bintools}/bin/strip -S -p "$out/libexec/gta2-launcher"

    # The launcher writes game/, saves/, data/, media/ and shader/ beside
    # itself.  A store path is read-only, so the wrapper copies the payload
    # launcher into a per-user writable directory and runs that copy.
    cat > "$out/bin/gta2-launcher" <<EOF
    #! ${stdenv.shell}
    set -eu
    if [ -n "\''${GTA2_RECOMP_DATA_DIR:-}" ]; then
      state="\$GTA2_RECOMP_DATA_DIR"
    else
      state="\''${XDG_DATA_HOME:-\''${HOME:?HOME is not set}/.local/share}/gta2-recompiled"
    fi
    mkdir -p "\$state"
    cp -f "$out/libexec/gta2-launcher" "\$state/gta2-launcher"
    chmod 755 "\$state/gta2-launcher"
    exec "\$state/gta2-launcher" "\$@"
    EOF
    chmod 755 "$out/bin/gta2-launcher"

    install -Dm644 assets/icon_256.png \
      "$out/share/icons/hicolor/256x256/apps/gta2-recompiled.png"

    payload=$PWD/payload
    mkdir -p "$payload"/{bin,config,lib,llvm/bin,python/bin,src,winrecomp}

    install -m644 tools/setup_build.py "$payload/setup_build.py"
    cp -r config/. "$payload/config/"
    install -m644 src/gta2_manual.c "$payload/src/gta2_manual.c"
    cp -r ${toolkit}/tools "$payload/winrecomp/"
    cp -r ${toolkit}/templates "$payload/winrecomp/"

    install -m644 build-port/libgta2_port.a "$payload/lib/libgta2_port.a"
    install -m644 build-port/winrecomp_rt/libwinrecomp_rt.a "$payload/lib/libwinrecomp_rt.a"
    install -m644 build-port/winrecomp_rt/shaderpack/libxbox_shaderpack.a \
      "$payload/lib/libxbox_shaderpack.a"
    install -m644 src/exports.dynlist "$payload/lib/exports.dynlist"
    install -m755 ${sdl3.lib}/lib/libSDL3.so.0 "$payload/lib/libSDL3.so.0"

    cat > "$payload/llvm/bin/clang" <<EOF
    #! /bin/sh
    exec ${clang}/bin/clang "\$@"
    EOF
    cat > "$payload/python/bin/python3" <<EOF
    #! /bin/sh
    exec ${python}/bin/python3 "\$@"
    EOF
    cat > "$payload/bin/unshield" <<EOF
    #! /bin/sh
    exec ${unshield}/bin/unshield "\$@"
    EOF
    chmod 755 "$payload/llvm/bin/clang" "$payload/python/bin/python3" "$payload/bin/unshield"

    tab=$'\t'
    cat > "$payload/toolchain.txt" <<EOF
    format''${tab}2
    clang''${tab}llvm/bin/clang
    python''${tab}python/bin/python3
    EOF

    cat > "$payload/lift.txt" <<EOF
    # check / extract run by themselves; the lift steps run in order.
    check''${tab}{TOOLS}/setup_build.py''${tab}check''${tab}--game''${tab}{GAME}
    extract''${tab}{TOOLS}/setup_build.py''${tab}extract''${tab}--installer''${tab}{INPUT}''${tab}--unshield''${tab}{TOOLS}/bin/unshield''${tab}--work''${tab}{WORK}''${tab}--game''${tab}{GAME}
    extract-folder''${tab}{TOOLS}/setup_build.py''${tab}extract''${tab}--folder''${tab}{INPUT}''${tab}--work''${tab}{WORK}''${tab}--game''${tab}{GAME}
    lift-gta2''${tab}{TOOLS}/setup_build.py''${tab}lift''${tab}--game''${tab}{GAME}''${tab}--toolkit''${tab}{TOOLS}/winrecomp''${tab}--config''${tab}{TOOLS}/config''${tab}--work''${tab}{WORK}''${tab}--module''${tab}gta2
    lift-bink''${tab}{TOOLS}/setup_build.py''${tab}lift''${tab}--game''${tab}{GAME}''${tab}--toolkit''${tab}{TOOLS}/winrecomp''${tab}--config''${tab}{TOOLS}/config''${tab}--work''${tab}{WORK}''${tab}--module''${tab}bink
    EOF

    cat > "$payload/build.txt" <<EOF
    cc''${tab}-x''${tab}c''${tab}-std=gnu11''${tab}-O2''${tab}-DNDEBUG''${tab}-w''${tab}-fwrapv''${tab}-fno-strict-aliasing''${tab}-fPIC
    glob''${tab}{WORK}/gen/gta2/src''${tab}.c
    glob''${tab}{WORK}/gen/bink/src''${tab}.c
    link''${tab}-fuse-ld=bfd''${tab}-pthread''${tab}{OBJECTS}''${tab}-Wl,--whole-archive''${tab}{TOOLS}/lib/libgta2_port.a''${tab}-Wl,--no-whole-archive''${tab}{TOOLS}/lib/libwinrecomp_rt.a''${tab}{TOOLS}/lib/libxbox_shaderpack.a''${tab}{TOOLS}/lib/libSDL3.so.0''${tab}-lm''${tab}-ldl''${tab}-Wl,--dynamic-list={TOOLS}/lib/exports.dynlist''${tab}-Wl,-rpath,\$ORIGIN''${tab}-o''${tab}{OUT}
    copy''${tab}{TOOLS}/lib/libSDL3.so.0''${tab}{DATA}/libSDL3.so.0
    EOF

    printf '%s' ${lib.escapeShellArg finalAttrs.version} > "$payload/release.txt"

    # The paths in the wrappers point into the store.  Keep those
    # derivations in the package's closure even though the payload is zipped.
    mkdir -p "$out/share/gta2-recompiled/deps"
    ln -s ${python} "$out/share/gta2-recompiled/deps/python"
    ln -s ${clang} "$out/share/gta2-recompiled/deps/clang"
    ln -s ${unshield} "$out/share/gta2-recompiled/deps/unshield"
    ln -s ${sdl3.lib} "$out/share/gta2-recompiled/deps/sdl3"

    python3 ${./make-payload.py} \
      --launcher "$out/libexec/gta2-launcher" \
      --payload "$payload" \
      --output "$out/libexec/gta2-launcher" \
      --release ${lib.escapeShellArg finalAttrs.version}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gta2-recompiled";
      desktopName = "Grand Theft Auto 2 Recompiled";
      comment = "GTA 2 rebuilt from your own freeware installer";
      exec = "gta2-launcher";
      icon = "gta2-recompiled";
      categories = [ "Game" ];
    })
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Native Grand Theft Auto 2 recompilation launcher (requires your own GTA 2 freeware copy)";
    longDescription = ''
      Grand Theft Auto 2 Recompiled is a native port of Grand Theft Auto 2
      made by static recompilation.  This package builds the launcher,
      runtime and lifter from source; it contains no game data or game code.
      On first start the launcher reads the 2004 Rockstar freeware installer
      (GTA2INSTALLER.exe) or an installed copy of that release, translates
      gta2.exe and binkw32.dll to C, compiles them for this machine, and
      starts the resulting game.  The installer is available at
      https://archive.org/details/gta2_rockstar-classics.
    '';
    homepage = "https://github.com/almost-drowned-rat/Grand-Theft-Auto-2-Recompiled";
    license = [
      lib.licenses.gpl3Plus
      lib.licenses.mit
    ];
    mainProgram = "gta2-launcher";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
