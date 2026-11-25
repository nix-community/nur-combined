{
  lib,
  stdenv,
  clangStdenv,
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
  libx11,
  libxcb,
  # Skate 3 Recompiled+ contains no game code or data: the build recompiles
  # the guest's default.xex and EAWebkit.xex, which come from your own
  # extracted retail disc. discImage defaults to the archive.org copy of the
  # disc, which the build unpacks for those two files; override it with your
  # own image, e.g.
  #   skate3recomp-plus.override { discImage = /path/to/Skate\ 3.iso; }
  # or pass the two executables from an extracted disc instead:
  #   skate3recomp-plus.override {
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
  # The codegen patches are written against the Title Update 3 payloads (Skate 3
  # title 454108E6, 3.0.0.0 -> 3.0.3.0) and do not apply to the base disc image
  # alone. The default archive carries both TU3 and TU4; only the TU3 STFS
  # container is unpacked from it. Override either input to use your own.
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
  version = "0.2e";

  src = fetchFromGitHub {
    owner = "dougieprishpreed";
    repo = "skate3recomp-plus";
    tag = "v${version}";
    hash = "sha256-CfHrcWKUlOEuBwZwCSB16xHu4erSZ6b9/+sHyg0G6wY=";
  };

  # The fork of rexglue the project builds against, with its patch and ImGui
  # pin; see sdk.nix for why this has to be a fixed-output derivation.
  sdk = import ./sdk.nix {
    inherit
      lib
      stdenvNoCC
      git
      cacert
      python3
      coreutils
      findutils
      ;
    gameSrc = src;
  };

  # The SDK pulls freetype in with FetchContent at configure time. The sandbox
  # has no network, so it gets the same tag as a pinned source directory.
  freetypeSrc = fetchFromGitHub {
    owner = "freetype";
    repo = "freetype";
    tag = "VER-2-13-3";
    hash = "sha256-4l90lDtpgm5xlh2m7ifrqNy373DTRTULRkAzicrM93c=";
  };

  python = python3.withPackages (ps: [ ps.numpy ]);
in
# The rexglue SDK refuses to configure with anything but Clang 18 or newer, so
# the build uses clangStdenv even where the default stdenv is GCC.
clangStdenv.mkDerivation {
  pname = "skate3recomp-plus";
  inherit version src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python
  ]
  ++ lib.optional (discImage != null) extract-xiso;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    libx11
    libxcb
  ];

  # sdk.nix applies the fork's SDK patch and stores the tree without git
  # metadata, so the configure-time "is the patch applied" check cannot run.
  # The SDK is also a git submodule the release tarball leaves empty, and some
  # of its sources are listed by their submodule path rather than through
  # REXSDK_DIR, so put our patched tree in the submodule's place. It is copied
  # rather than linked because the SDK's build links its own libraries into
  # ${REXSDK_DIR}/out, which a store path does not allow.
  postPatch = ''
    substituteInPlace cmake/RexGlue.cmake \
      --replace-fail 'if(NOT _skate3_sdk_patch_result EQUAL 0)' 'if(FALSE)'
    rm -rf third_party/rexglue-sdk
    cp -a ${sdk} third_party/rexglue-sdk
    chmod -R u+w third_party/rexglue-sdk
    # The recompiler segfaults while exiting (its cvar registrars unregister
    # after the registry is destroyed), which fails every codegen target even
    # though the code was written. See the patch for the fix.
    patch -p1 -d third_party/rexglue-sdk --input ${./rexglue-cli-skip-static-dtors.patch}
  '';

  dontConfigure = true;

  # The code generator writes generated/ into the source tree, which
  # unpackPhase leaves read-write.
  buildPhase = ''
    runHook preBuild

    ${lib.optionalString (discImage == null && (defaultXex == null || eaWebkitXex == null)) ''
      echo "skate3recomp-plus: the build recompiles the game from your own Skate 3 disc." >&2
      echo "Override the package with the disc image, or with the two executables" >&2
      echo "from an extracted disc:" >&2
      echo "  nix build --impure --expr 'with import ./. {}; skate3recomp-plus.override {" >&2
      echo "    discImage = /path/to/Skate\ 3.iso; }'" >&2
      echo "  nix build --impure --expr 'with import ./. {}; skate3recomp-plus.override {" >&2
      echo "    defaultXex = /path/to/Skate3-disc/default.xex;" >&2
      echo "    eaWebkitXex = /path/to/Skate3-disc/data/webkit/EAWebkit.xex; }'" >&2
      exit 1
    ''}

    ${lib.optionalString (titleUpdatePackage == null) ''
      echo "skate3recomp-plus: codegen is generated against the Title Update 3 payloads" >&2
      echo "(Skate 3 title 454108E6, 3.0.0.0 -> 3.0.3.0), so the TU3 package is required;" >&2
      echo "its patches do not apply to the base disc image. Override the package with" >&2
      echo "your own TU3 package:" >&2
      echo "  skate3recomp-plus.override {" >&2
      echo "    titleUpdatePackage = /path/to/TU_12K2276_000000C000000.00000000000O3; }" >&2
      exit 1
    ''}

    # Only these two files are read at build time; the game's assets are
    # installed at run time from the player's own disc.
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

    ${lib.optionalString (titleUpdatePackage != null) ''
      install -m444 ${toString titleUpdatePackage} ./TU_12K2276_000000C000000.00000000000O3
    ''}

    cmake_args=(
      -G Ninja
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -DREXSDK_DIR="$PWD/third_party/rexglue-sdk"
      -DREXGLUE_USE_VULKAN=ON
      -DREXGLUE_ENABLE_TRACY=OFF
      -DSKATE3_GAME_DATA_ROOT="$PWD/game"
      -DSKATE3_STAGE_INSTALLER=OFF
      -DFETCHCONTENT_SOURCE_DIR_FREETYPE=${freetypeSrc}
      -DPython3_EXECUTABLE=${python}/bin/python3
    )
    ${lib.optionalString (titleUpdatePackage != null) ''
      cmake_args+=(-DSKATE3_TITLE_UPDATE_PACKAGE="$PWD/TU_12K2276_000000C000000.00000000000O3")
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
    [ -f "$bin_dir/settings.toml" ] && install -Dm644 "$bin_dir/settings.toml" "$out/bin/settings.toml"
    runHook postInstall
  '';

  passthru = {
    inherit sdk;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Enhanced native Skate 3 recompilation (needs your own disc)";
    longDescription = ''
      Skate 3 Recompiled+ adds Skate 2's New San Vanelona, a native Vulkan
      renderer and fixes to a recompilation of Skate 3. It ships no game data:
      the build recompiles default.xex from your own extracted retail disc,
      and the game is installed from that disc at run time.
    '';
    homepage = "https://github.com/dougieprishpreed/skate3recomp-plus";
    # No license file in the repository; it is built on the rexglue SDK and
    # states no terms of its own.
    license = lib.licenses.unfree;
    mainProgram = "skate3";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
  };
}
