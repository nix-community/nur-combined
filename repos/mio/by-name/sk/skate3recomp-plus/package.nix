{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  git,
  cacert,
  python3,
  coreutils,
  findutils,
  cmake,
  ninja,
  pkg-config,
  gtk3,
  xorg,
  # Skate 3 Recompiled+ contains no game code or data: the build recompiles
  # the guest's default.xex and EAWebkit.xex, which come from your own
  # extracted retail disc. Point these at those two files, e.g.
  #   skate3recomp-plus.override {
  #     defaultXex = /path/to/Skate3-disc/default.xex;
  #     eaWebkitXex = /path/to/Skate3-disc/data/webkit/EAWebkit.xex;
  #   }
  defaultXex ? null,
  eaWebkitXex ? null,
  # Optional Skate 3 Title Update 3 STFS package used for codegen, e.g.
  #   titleUpdatePackage = /path/to/TU_12K2276_000000C000000.00000000000O3;
  titleUpdatePackage ? null,
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
    rev = "7eb0faf7787f5e01333c228b8e3f03c32f7295ea";
  };

  python = python3.withPackages (ps: [ ps.numpy ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "skate3recomp-plus";
  inherit version src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    xorg.libX11
    xorg.libxcb
  ];

  # sdk.nix applies the fork's SDK patch and stores the tree without git
  # metadata, so the configure-time "is the patch applied" check cannot run.
  postPatch = ''
    substituteInPlace cmake/RexGlue.cmake \
      --replace-fail 'if(NOT _skate3_sdk_patch_result EQUAL 0)' 'if(FALSE)'
  '';

  dontConfigure = true;

  # The code generator writes generated/ into the source tree, which
  # unpackPhase leaves read-write.
  buildPhase = ''
    runHook preBuild

    ${lib.optionalString (defaultXex == null || eaWebkitXex == null) ''
      echo "skate3recomp-plus: the build recompiles the game from your own Skate 3 disc." >&2
      echo "Extract the disc and override the package with the two executables:" >&2
      echo "  nix build --impure --expr 'with import ./. {}; skate3recomp-plus.override {" >&2
      echo "    defaultXex = /path/to/Skate3-disc/default.xex;" >&2
      echo "    eaWebkitXex = /path/to/Skate3-disc/data/webkit/EAWebkit.xex; }'" >&2
      exit 1
    ''}

    # Only these two files are read at build time; the game's assets are
    # installed at run time from the player's own disc.
    mkdir -p game/data/webkit
    install -m444 ${toString defaultXex} game/default.xex
    install -m444 ${toString eaWebkitXex} game/data/webkit/EAWebkit.xex

    ${lib.optionalString (titleUpdatePackage != null) ''
      install -m444 ${toString titleUpdatePackage} ./TU_12K2276_000000C000000.00000000000O3
    ''}

    cmake_args=(
      -G Ninja
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -DREXSDK_DIR=${sdk}
      -DREXGLUE_USE_VULKAN=ON
      -DREXGLUE_ENABLE_TRACY=OFF
      -DSKATE3_GAME_DATA_ROOT="$PWD/game"
      -DSKATE3_STAGE_INSTALLER=OFF
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
})
