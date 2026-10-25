{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchFromCodeberg,
  cmake,
  boost,
  expat,
  getopt,
  gflags,
  glm,
  gtest,
  freetype,
  harfbuzz,
  icu,
  imgui,
  jansson,
  jq,
  libxcursor,
  libxinerama,
  libxrandr,
  ninja,
  pkg-config,
  pugixml,
  python3,
  qt6,
  optipng,
  utf8cpp,
  which,
  nix-update-script,
}:
let
  world_feed_integration_tests_data = fetchFromGitHub {
    owner = "organicmaps";
    repo = "world_feed_integration_tests_data";
    rev = "30ecb0b3fe694a582edfacc2a7425b6f01f9fec6";
    hash = "sha256-1FF658OhKg8a5kKX/7TVmsxZ9amimn4lB6bX9i7pnI4=";
  };

  # Update mapRev based on v field and mapSeries near the top in https://codeberg.org/comaps/comaps/src/branch/main/data/countries.txt
  mapSeries = "2026.06.28";
  mapRev = 260830;

  worldMap = fetchurl {
    name = "World-${mapSeries}-${toString mapRev}.mwm";
    url = "https://mapgen-fi-1.comaps.app/maps/${mapSeries}/${toString mapRev}/World.mwm";
    hash = "sha256-TcaGJK8xAkceA7wFsCrYt6euOnts0w7LZCKLFPnU3wM=";
  };

  worldCoasts = fetchurl {
    name = "WorldCoasts-${mapSeries}-${toString mapRev}.mwm";
    url = "https://mapgen-fi-1.comaps.app/maps/${mapSeries}/${toString mapRev}/WorldCoasts.mwm";
    hash = "sha256-pNb0cLGRN6YkliraL+DZyAPh+JJSM6vTzoejeKvi/oc=";
  };

  pythonEnv = python3.withPackages (
    ps: with ps; [
      protobuf
    ]
  );
in
stdenv.mkDerivation (
  finalAttrs:
  {
    pname = "comaps";
    version = "2026.10.05-19";

    strictDeps = true;
    __structuredAttrs = true;

    src = fetchFromCodeberg {
      owner = "comaps";
      repo = "comaps";
      tag = "v${finalAttrs.version}";
      hash = "sha256-EN23jI+o1AFuCDig2+ZTx96PvshruyuwKZguqWHcG8Q=";
      fetchSubmodules = true;
    };

    patches = [
      ./use-vendored-protobuf.patch
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # System FreeType/HarfBuzz/ICU, and load ICU data from the Nix library.
      ./darwin-system-text-libs.patch
    ];

    postPatch = ''
      patchShebangs 3party/boost/tools/build/src/engine/build.sh

      ln -s ${world_feed_integration_tests_data} data/test_data/world_feed_integration_tests_data

      rm -f 3party/boost/b2
      substituteInPlace configure.sh \
        --replace-fail "git submodule update --init --recursive --depth 1" ""

      patchShebangs tools/unix/*
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # dev_sandbox needs the Metal shader compiler (unavailable in the Nix sandbox)
      # and is not part of the shipped app.
      substituteInPlace CMakeLists.txt \
        --replace-fail "  add_subdirectory(dev_sandbox)" ""
    ''
    + ''
      # configure.sh builds skin_generator_tool with its own cmake invocation;
      # make it use system dependencies like the main build.
      substituteInPlace tools/unix/generate_symbols.sh \
        --replace-fail 'CMAKE_EXTRA_ARGS=""' 'CMAKE_EXTRA_ARGS="-DWITH_SYSTEM_PROVIDED_3PARTY=ON -DCMAKE_C_COMPILER_AR=$(command -v "$AR") -DCMAKE_CXX_COMPILER_AR=$(command -v "$AR") -DCMAKE_C_COMPILER_RANLIB=$(command -v "$RANLIB") -DCMAKE_CXX_COMPILER_RANLIB=$(command -v "$RANLIB")"'
      substituteInPlace tools/python/{categories/json_to_txt.py,generate_desktop_ui_strings.py} \
        --replace-fail "/usr/bin/env python3" "${pythonEnv.interpreter}"
    '';

    nativeBuildInputs = [
      cmake
      ninja
      jq
      icu
      getopt
      which
      pkg-config
      pythonEnv
      qt6.wrapQtAppsHook
      optipng
    ];

    buildInputs = [
      qt6.qtbase
      qt6.qtpositioning
      qt6.qtsvg

      boost
      expat
      gtest
      gflags
      glm
      imgui
      jansson
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libxcursor
      libxinerama
      libxrandr
    ]
    ++ [
      pugixml
      utf8cpp
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      freetype
      harfbuzz
      icu
    ];

    preConfigure =
      lib.optionalString stdenv.hostPlatform.isDarwin ''
        # /build/source is the Linux sandbox path. Darwin builds under $NIX_BUILD_TOP.
        # Must be set before configure.sh, which builds skin_generator_tool.
        export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE:+$NIX_CFLAGS_COMPILE }-I$PWD/3party/fast_double_parser/include"
      ''
      + ''
        bash ./configure.sh --skip-map-download
      '';

    cmakeFlags = [
      (lib.cmakeBool "SKIP_TESTS" false)
      (lib.cmakeBool "WITH_SYSTEM_PROVIDED_3PARTY" true)
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # With -flto, CMake looks for the compiler's LTO-aware ar/ranlib and
      # leaves them as *-NOTFOUND with the Nix clang wrapper.
      (lib.cmakeFeature "CMAKE_C_COMPILER_AR" "${stdenv.cc.bintools.targetPrefix}ar")
      (lib.cmakeFeature "CMAKE_CXX_COMPILER_AR" "${stdenv.cc.bintools.targetPrefix}ar")
      (lib.cmakeFeature "CMAKE_C_COMPILER_RANLIB" "${stdenv.cc.bintools.targetPrefix}ranlib")
      (lib.cmakeFeature "CMAKE_CXX_COMPILER_RANLIB" "${stdenv.cc.bintools.targetPrefix}ranlib")
    ];

    env = {
      NIX_CFLAGS_COMPILE = toString [
        "-I/build/source/3party/fast_double_parser/include"
      ];
      PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
      SKIP_PYTHON_VENV = 1;
    };

    postInstall = ''
      install -Dm644 ${worldMap} $out/share/comaps/data/World.mwm
      install -Dm644 ${worldCoasts} $out/share/comaps/data/WorldCoasts.mwm
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      bundle="$out/bin/CoMaps.app/Contents/Resources"
      if [ ! -d "$bundle" ]; then
        echo "CoMaps.app resources directory was not installed" >&2
        find "$out" -maxdepth 4 -print >&2
        exit 1
      fi
      install -m644 ${worldMap} "$bundle/World.mwm"
      install -m644 ${worldCoasts} "$bundle/WorldCoasts.mwm"
    '';

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "-vr"
        "v(.*)"
      ];
    };

    meta = {
      description = "Community-led fork of Organic Maps";
      homepage = "https://comaps.app";
      downloadPage = "https://comaps.app/download";
      donationPage = "https://comaps.app/donate";
      changelog = "https://codeberg.org/comaps/comaps/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.asl20;
      maintainers = [ lib.maintainers.ryand56 ];
      platforms = lib.platforms.unix;
      mainProgram = "CoMaps";
    };
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # macOS installs CoMaps.app; nix run looks for bin/CoMaps. Create that after
    # wrapQtAppsHook rewrites the Mach-O inside the bundle.
    postFixup = ''
      exe="$out/bin/CoMaps.app/Contents/MacOS/CoMaps"
      if [ ! -x "$exe" ]; then
        echo "CoMaps.app executable was not installed" >&2
        exit 1
      fi
      if [ ! -e "$out/bin/CoMaps" ]; then
        mkdir -p "$out/bin"
        makeWrapper "$exe" "$out/bin/CoMaps"
      fi
    '';
  }
)
