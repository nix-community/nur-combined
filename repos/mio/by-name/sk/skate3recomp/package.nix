{
  lib,
  clangStdenv,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  git,
  cacert,
  python3,
  coreutils,
  findutils,
  runCommandLocal,
  cmake,
  ninja,
  pkg-config,
  extract-xiso,
  unzip,
  gtk3,
  gsettings-desktop-schemas,
  libx11,
  libxcb,
  alsa-lib,
  libpulseaudio,
  pipewire,
  libudev-zero,
  libusb1,
  libunwind,
  liburing,
  vulkan-loader,
  moltenvk,
  makeWrapper,
  wrapGAppsHook3,
  # The source contains no game code. Code generation recompiles the guest's
  # default.xex and EAWebkit.xex, and runtime setup extracts the full game from
  # the same disc image. discImage defaults to the archive.org copy; override
  # it with your own image, e.g.
  #   skate3recomp.override { discImage = /path/to/Skate\ 3.iso; }
  # or pass the two executables from an extracted disc instead:
  #   skate3recomp.override {
  #     discImage = null;
  #     defaultXex = /path/to/Skate3-disc/default.xex;
  #     eaWebkitXex = /path/to/Skate3-disc/data/webkit/EAWebkit.xex;
  #   }
  defaultXex ? null,
  eaWebkitXex ? null,
  discImage ? fetchurl {
    name = "Skate_3.iso";
    url = "https://ia800405.us.archive.org/8/items/skate-3_202405/Skate%203.iso";
    hash = "sha256-0hsrtoSG2No9Txw1y0jIS7jiKp9s1FVTIwA8JJAqDD8=";
  },
  # Code generation is built against the Title Update 3 payloads (Skate 3
  # title 454108E6, 3.0.0.0 -> 3.0.3.0). The default archive also carries TU4;
  # only the TU3 STFS container is unpacked from it.
  titleUpdateZip ? fetchurl {
    name = "Skate3TU4_TU3.zip";
    url = "https://web.archive.org/web/20261125184301if_/https://download.digiex.net/Consoles/Xbox360/TitleUpdates/Skate3TU4_TU3.zip";
    hash = "sha256-9SoKCNnaIzkpHvbBcRKWRgAzrwG4o9eocBhOc1dOSVw=";
  },
  titleUpdatePackage ?
    runCommandLocal "TU_12K2276_000000C000000.00000000000O3"
      {
        nativeBuildInputs = [ unzip ];
      }
      ''
        unzip -p ${titleUpdateZip} TU_12K2276_000000C000000.00000000000O3 > $out
        chmod 444 $out
      '',
}:

let
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "mchughalex";
    repo = "skate3recomp";
    tag = "v${version}";
    hash = "sha256-XELBJVIo89X70dMIHTdDly1caPO/dwoDEJZWSKpHxSc=";
  };

  sdk = import ./sdk.nix {
    inherit
      lib
      stdenvNoCC
      git
      cacert
      coreutils
      findutils
      ;
  };

  # The SDK pulls freetype in with FetchContent at configure time. The sandbox
  # has no network, so it gets the same tag as a pinned source directory.
  freetypeSrc = fetchFromGitHub {
    owner = "freetype";
    repo = "freetype";
    tag = "VER-2-13-3";
    hash = "sha256-4l90lDtpgm5xlh2m7ifrqNy373DTRTULRkAzicrM93c=";
  };
in
# The rexglue SDK refuses to configure with anything but Clang 18 or newer, so
# the build uses clangStdenv even where the default stdenv is GCC.
clangStdenv.mkDerivation {
  pname = "skate3recomp";
  inherit version src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
  ]
  ++ lib.optional (discImage != null) extract-xiso
  ++ lib.optional stdenv.hostPlatform.isLinux wrapGAppsHook3
  ++ lib.optional stdenv.hostPlatform.isDarwin makeWrapper;

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      gtk3
      gsettings-desktop-schemas
      libx11
      libxcb
      alsa-lib
      libpulseaudio
      pipewire
      libudev-zero
      libusb1
      libunwind
      liburing
      # volk dlopens the Vulkan loader by name, so nothing links it.
      vulkan-loader
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # The runtime reaches Vulkan through volk, which dlopens the loader by
      # name. The loader picks the driver from the ICD manifest.
      moltenvk
      vulkan-loader
    ];

  # The release tarball leaves the SDK submodule empty. Put our reproducible
  # checkout in its place; it is copied rather than linked because the SDK's
  # build links its own libraries into ${REXSDK_DIR}/out.
  postPatch = ''
    # The checkout has no .git metadata, so CMake cannot derive the release
    # version from the tag. Use the package version as the floor instead of
    # letting the binary report 2.0.0-dev.unknown.
    sed -i -E 's/project\(skate3 VERSION [0-9.]+/project(skate3 VERSION ${version}/' CMakeLists.txt
    rm -rf third_party/rexglue-sdk
    cp -a ${sdk} third_party/rexglue-sdk
    chmod -R u+w third_party/rexglue-sdk
    # The recompiler segfaults while exiting (its cvar registrars unregister
    # after the registry is destroyed), which fails every codegen target even
    # though the code was written. See the patch for the fix.
    patch -p1 -d third_party/rexglue-sdk --input ${./rexglue-cli-skip-static-dtors.patch}
    # The SDK's pinned ImGui commit is gone from upstream. The served revision
    # used in its place has no RasterizerGamma field, so drop the assignments
    # that reference it.
    patch -p1 -d third_party/rexglue-sdk --input ${./rexglue-imgui-rasterizer-gamma.patch}
    # The executable lives in the read-only store, so the SDK's default log
    # directory next to it cannot be created at startup.
    patch -p1 -d third_party/rexglue-sdk --input ${./rexglue-log-dir-fallback.patch}
    # Likewise, game files must be installed under user data rather than next
    # to the store executable.
    patch -p1 --input ${./game-data-user-root.patch}
  '';

  dontConfigure = true;

  # The code generator writes generated/ into the source tree, which
  # unpackPhase leaves read-write.
  buildPhase = ''
    runHook preBuild

    ${lib.optionalString (discImage == null && (defaultXex == null || eaWebkitXex == null)) ''
      echo "skate3recomp: the build recompiles the game from your own Skate 3 disc." >&2
      echo "Override the package with the disc image, or with the two executables" >&2
      echo "from an extracted disc:" >&2
      echo "  nix build --impure --expr 'with import ./. {}; skate3recomp.override {" >&2
      echo "    discImage = /path/to/Skate\ 3.iso; }'" >&2
      echo "  nix build --impure --expr 'with import ./. {}; skate3recomp.override {" >&2
      echo "    defaultXex = /path/to/Skate3-disc/default.xex;" >&2
      echo "    eaWebkitXex = /path/to/Skate3-disc/data/webkit/EAWebkit.xex; }'" >&2
      exit 1
    ''}

    ${lib.optionalString (titleUpdatePackage == null) ''
      echo "skate3recomp: codegen is generated against the Title Update 3 payloads" >&2
      echo "(Skate 3 title 454108E6, 3.0.0.0 -> 3.0.3.0), so the TU3 package is required;" >&2
      echo "its patches do not apply to the base disc image. Override the package with" >&2
      echo "your own TU3 package:" >&2
      echo "  skate3recomp.override {" >&2
      echo "    titleUpdatePackage = /path/to/TU_12K2276_000000C000000.00000000000O3; }" >&2
      exit 1
    ''}

    # Only these two files are read during code generation. The full disc is
    # linked beside the executable so first-run setup can install the game.
    mkdir -p game/data/webkit
    ${lib.optionalString (discImage != null) ''
      # extract-xiso has no single-file mode, so unpack the disc and keep only
      # the two executables the recompiler reads.
      extract-xiso -q -x -d disc ${toString discImage}
      install -m444 disc/default.xex game/default.xex
      install -m444 disc/data/webkit/EAWebkit.xex game/data/webkit/EAWebkit.xex
      rm -rf disc
    ''}
    ${lib.optionalString (discImage == null) ''
      install -m444 ${toString defaultXex} game/default.xex
      install -m444 ${toString eaWebkitXex} game/data/webkit/EAWebkit.xex
    ''}

    cmake_args=(
      -G Ninja
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -DREXSDK_DIR="$PWD/third_party/rexglue-sdk"
      -DREXGLUE_USE_VULKAN=ON
      -DREXGLUE_ENABLE_TRACY=OFF
      -DSKATE3_GAME_DATA_ROOT="$PWD/game"
      -DFETCHCONTENT_SOURCE_DIR_FREETYPE=${freetypeSrc}
      -DPython3_EXECUTABLE=${python3}/bin/python3
    )
    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      # Upstream's macOS runner sets this explicitly; both the game and the SDK
      # are ARM64-only on Darwin.
      cmake_args+=(-DCMAKE_OSX_ARCHITECTURES=arm64)
    ''}
    ${lib.optionalString (titleUpdatePackage != null) ''
      cmake_args+=(-DSKATE3_TITLE_UPDATE_PACKAGE=${toString titleUpdatePackage})
    ''}

    cmake -S . -B build "''${cmake_args[@]}"
    cmake --build build --target generate-all -j''${NIX_BUILD_CORES:-1}
    # The generated source lists are picked up by a second configure.
    cmake -S . -B build "''${cmake_args[@]}"
    cmake --build build --target skate3 -j''${NIX_BUILD_CORES:-1}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    bin_dir=$(dirname "$(find . -type f -name skate3 -perm -u+x -print -quit)")
    install -Dm755 "$bin_dir/skate3" "$out/bin/skate3"
    for lib in "$bin_dir"/*.so* "$bin_dir"/*.dylib; do
      [ -e "$lib" ] && cp -a "$lib" "$out/bin/"
    done
    mkdir -p "$out/share/skate3recomp"
    ${lib.optionalString (discImage != null) ''
      ln -s ${discImage} "$out/share/skate3recomp/Skate_3.iso"
    ''}
    ${lib.optionalString (titleUpdatePackage != null) ''
      ln -s ${titleUpdatePackage} "$out/share/skate3recomp/TU3"
    ''}
    runHook postInstall
  '';

  # volk reaches the Vulkan loader through dlopen rather than a DT_NEEDED
  # entry. Upstream's macOS package also copies MoltenVK and its ICD manifest
  # next to the executable; the store paths are used instead.
  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}
    )
  '';

  dontWrapGApps = stdenv.hostPlatform.isLinux;

  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/skate3 "''${gappsWrapperArgs[@]}" \
        ${
          lib.optionalString (discImage != null) ''
            --set SKATE3_INSTALL_ISO "$out/share/skate3recomp/Skate_3.iso" \
          ''
        }${
          lib.optionalString (titleUpdatePackage != null) ''
            --set SKATE3_INSTALL_TU "$out/share/skate3recomp/TU3" \
          ''
        }
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      wrapProgram $out/bin/skate3 \
        --prefix DYLD_FALLBACK_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            vulkan-loader
            moltenvk
          ]
        } \
        --set VK_ICD_FILENAMES ${moltenvk}/share/vulkan/icd.d/MoltenVK_icd.json \
        ${
          lib.optionalString (discImage != null) ''
            --set SKATE3_INSTALL_ISO "$out/share/skate3recomp/Skate_3.iso" \
          ''
        }${
          lib.optionalString (titleUpdatePackage != null) ''
            --set SKATE3_INSTALL_TU "$out/share/skate3recomp/TU3" \
          ''
        }
    '';

  passthru = {
    inherit sdk;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Native Skate 3 recompilation";
    longDescription = ''
      A native recompilation of Skate 3 for Linux and Apple Silicon macOS. The
      source ships no game data: the pinned disc image is used for code
      generation and first-run setup, and the title update is installed from
      the pinned TU3 package.
    '';
    homepage = "https://github.com/mchughalex/skate3recomp";
    # No license file in the repository; it is built on the rexglue SDK and
    # states no license of its own.
    license = lib.licenses.unfree;
    mainProgram = "skate3";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
  };
}
