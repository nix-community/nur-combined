{
  lib,
  stdenv,
  comaps,
  makeWrapper,

  freetype,
  harfbuzz,
  icu,
}:

# nixpkgs' comaps only builds on Linux and is marked broken on Darwin. The
# desktop app has a macOS target too; these overrides fill in what the Linux
# packaging assumes: system FreeType/HarfBuzz/ICU, an app-bundle install
# location, and a bin wrapper so `nix run` and PATH launches work.
comaps.overrideAttrs (old: {
  pname = "comaps_patched";

  patches =
    (old.patches or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      ./darwin-system-text-libs.patch
    ];

  postPatch =
    (old.postPatch or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # dev_sandbox needs the Metal shader compiler (unavailable in the Nix sandbox)
      # and is not part of the shipped app.
      substituteInPlace CMakeLists.txt \
        --replace-fail "  add_subdirectory(dev_sandbox)" ""

      # configure.sh runs this on Darwin and hardcodes Homebrew's icu4c;
      # the icu we put on PATH below already provides uconv.
      substituteInPlace tools/unix/generate_serbian_latin_strings.sh \
        --replace-fail 'export PATH="$(brew --prefix icu4c)/bin:$PATH"' ":"

    '';

  preConfigure =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      # /build/source is the Linux sandbox path. Darwin builds under $NIX_BUILD_TOP.
      # Must be set before configure.sh, which builds skin_generator_tool.
      export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE:+$NIX_CFLAGS_COMPILE }-I$PWD/3party/fast_double_parser/include"

      # The checked-in symbols are used as-is; generating them builds
      # skin_generator_tool with a separate, Darwin-hostile cmake setup.
      bash ./configure.sh --skip-map-download --skip-generate-symbols
    ''
    + lib.optionalString (!stdenv.hostPlatform.isDarwin) (old.preConfigure or "");

  cmakeFlags =
    (old.cmakeFlags or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # With -flto, CMake looks for the compiler's LTO-aware ar/ranlib and
      # leaves them as *-NOTFOUND with the Nix clang wrapper.
      (lib.cmakeFeature "CMAKE_C_COMPILER_AR" "${stdenv.cc.bintools.targetPrefix}ar")
      (lib.cmakeFeature "CMAKE_CXX_COMPILER_AR" "${stdenv.cc.bintools.targetPrefix}ar")
      (lib.cmakeFeature "CMAKE_C_COMPILER_RANLIB" "${stdenv.cc.bintools.targetPrefix}ranlib")
      (lib.cmakeFeature "CMAKE_CXX_COMPILER_RANLIB" "${stdenv.cc.bintools.targetPrefix}ranlib")
      # Install the MACOSX_BUNDLE target into $out/Applications/ (macOS
      # convention) instead of the GNUInstallDirs default of $out/bin/.
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "Applications")
    ];

  nativeBuildInputs =
    (old.nativeBuildInputs or [ ]) ++ lib.optionals stdenv.hostPlatform.isDarwin [ icu ];

  buildInputs =
    (old.buildInputs or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      freetype
      harfbuzz
      icu
    ];

  postInstall =
    (old.postInstall or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      bundle="$out/Applications/CoMaps.app/Contents/Resources"
      if [ ! -d "$bundle" ]; then
        echo "CoMaps.app resources directory was not installed" >&2
        find "$out" -maxdepth 4 -print >&2
        exit 1
      fi
      install -m644 "$out/share/comaps/data/World.mwm" "$bundle/World.mwm"
      install -m644 "$out/share/comaps/data/WorldCoasts.mwm" "$bundle/WorldCoasts.mwm"
      # categories_brands.txt is in the source data/ dir but omitted from
      # upstream's data file list; install it manually into the bundle.
      install -m644 "$NIX_BUILD_TOP/source/data/categories_brands.txt" "$bundle/categories_brands.txt"
    '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    exe="$out/Applications/CoMaps.app/Contents/MacOS/CoMaps"
    if [ ! -x "$exe" ]; then
      echo "CoMaps.app executable was not installed" >&2
      exit 1
    fi
    mkdir -p "$out/bin"
    makeWrapper "$exe" "$out/bin/CoMaps"
  '';

  meta = (old.meta or { }) // {
    broken = false;
  };
})
