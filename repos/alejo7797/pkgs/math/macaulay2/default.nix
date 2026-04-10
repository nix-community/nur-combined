{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchzip,
  fetchpatch2,
  makeDesktopItem,

  # Build deps
  bison,
  cmake,
  ctestCheckHook,
  ninja,
  pkg-config,
  texlive,
  copyDesktopItems,

  # Libraries
  blas,
  boehmgc,
  boost,
  cddlib,
  eigen,
  fflas-ffpack,
  flint,
  frobby,
  gdbm,
  givaro,
  glpk,
  gmp,
  gtest,
  libffi,
  libxml2,
  mpfi,
  mpfr,
  mpsolve,
  msolve,
  nauty,
  normaliz,
  ntl,
  onetbb,
  python3,
  readline,
  singular,

  # Programs
  _4ti2,
  cohomcalg,
  csdp,
  gfan,
  lrs,
  rWrapper,
  R,
  topcom,
}:

let
  m2ProgramPath = lib.makeBinPath [
    _4ti2
    cohomcalg
    csdp
    gfan
    lrs
    msolve
    nauty
    normaliz
    R
    topcom
  ];

  m2LibraryPath = lib.makeLibraryPath [
    cddlib
    flint
    givaro
    glpk
    mpfi
    mpfr
    mpsolve
    msolve
    normaliz
    ntl
    singular
  ];

  macaulay2-icons = fetchzip {
    url = "https://src.fedoraproject.org/repo/pkgs/Macaulay2/Macaulay2-icons.tar.xz/sha512/069aa0ad70a0253583b00091c094da9b79d2a2f0f2d38aa97f543081f5df5fd3b5a9e1463febd6947c3151cf01844133174c7372f57e158c2d3faba6baed5d1d/Macaulay2-icons.tar.xz";
    hash = "sha256-nsLizDmsfEOpZVgDASc3K3w6K3hVUoQgCoVwxBDpjXg=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "macaulay2";
  version = "1.25.11";

  src = fetchFromGitHub {
    owner = "Macaulay2";
    repo = "M2";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-MX3PRBIXbzaGJYbPRBdLE9/D7WbhVQGpmZuo45wJjcs=";
    fetchSubmodules = true;
  };

  sourceRoot = "${finalAttrs.src.name}/M2";

  patches = [
    # Set `$PATH` and `$LD_LIBRARY_PATH` appropriately.
    ./runtime-deps.patch

    # FIXME: This should ideally get upstreamed.
    (fetchpatch2 {
      name = "gbtrace-default.patch";
      url = "https://github.com/Macaulay2/M2/commit/c9cdf395e0d9eddbc604ba5d668c9b80e3a7254f.patch?full_index=1";
      stripLen = 1;
      hash = "sha256-1TnnAH0bj1j5ciFP12OjFJ8lfmBpYtm0PuP/e3s4VPY=";
    })

    # FIXME: This should ideally get upstreamed.
    (fetchpatch2 {
      name = "cache-example-output.patch";
      url = "https://github.com/Macaulay2/M2/commit/4d6e6e34f4e66a042535f0c0260432a1b3dbee65.patch?full_index=1";
      stripLen = 1;
      hash = "sha256-2SulNuhucTQ8K7Q3P1xjKmjg9mRrHEZsrRBwzLA5TU0=";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ctestCheckHook
    ninja
    pkg-config
    bison
    texlive.combined.scheme-basic
    copyDesktopItems
  ];

  buildInputs = [
    blas
    boehmgc
    boost
    cddlib
    frobby
    gdbm
    glpk
    gmp
    eigen
    fflas-ffpack
    flint
    givaro
    gtest
    libffi
    libxml2
    mpfi
    mpfr
    mpsolve
    msolve
    nauty
    normaliz
    ntl
    onetbb
    python3
    readline
    singular
  ];

  env = {
    # Needed to satisfy calls to `find_program()`.
    CMAKE_PROGRAM_PATH = m2ProgramPath;
  };

  cmakeFlags = [
    # Used in our patched M2 wrapper script.
    (lib.cmakeFeature "NIXPKGS_M2_PROGRAM_PATH" m2ProgramPath)
    (lib.cmakeFeature "NIXPKGS_M2_LIBRARY_PATH" m2LibraryPath)

    # NOTE: M2 opens `libR.so` directly; adding `rWrapper` to `$PATH` is not enough.
    (lib.cmakeFeature "NIXPKGS_M2_R_LIBS_SITE" (
      lib.makeSearchPath "library" rWrapper.recommendedPackages
    ))

    # Disable native x86_64 SIMD instructions.
    (lib.cmakeBool "BUILD_NATIVE" false)

    # Do not copy packages' example output back to the source tree.
    (lib.cmakeFeature "CacheExampleOutput" "false")

    # NOTE: Upstream has reasons (?) to pass in `NO_DEFAULT_PATH`.
    # See: https://github.com/Macaulay2/M2/issues/2218
    (lib.cmakeOptionType "path" "READLINE_ROOT_DIR" "${lib.getDev readline}")

    # Upstream expects these to be relative.
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_DATAROOTDIR" "share")
    (lib.cmakeFeature "CMAKE_INSTALL_DOCDIR" "share/doc/Macaulay2")
    (lib.cmakeFeature "CMAKE_INSTALL_INFODIR" "share/info")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBEXECDIR" "libexec")
    (lib.cmakeFeature "CMAKE_INSTALL_MANDIR" "share/man")
  ];

  postConfigure = ''
    # FIXME: Reconfigure `include/M2/config.h` with the correct value for `PACKAGES`.
    # See: https://github.com/Macaulay2/M2/blob/release-1.25.11/M2/include/M2/config.h.cmake#L296
    cmake .
  '';

  postBuild = ''
    # WARN: Generate the package documentation. Takes a *very* long time to finish.
    TERM=dumb ninja "''${flagsArray[@]}" install-packages
  '';

  doCheck = true;

  preCheck = ''
    # https://github.com/Macaulay2/M2/issues/1706#issuecomment-747592740
    TERM=dumb ninja M2-tests-ComputationsBook

    # FIXME: Reconfigure to pick up the 4000+ package tests.
    # See: https://github.com/Macaulay2/M2/blob/release-1.25.11/M2/Macaulay2/packages/CMakeLists.txt#L224
    cmake .
  '';

  ctestFlags = [
    # https://github.com/Macaulay2/M2/issues/1213
    "--exclude-regex"
    "^(engine|goals|quarantine)/"
  ];

  disabledTests = [
    # https://github.com/Macaulay2/M2/issues/3571
    "check-Depth-1"

    # https://github.com/Macaulay2/M2/issues/3238
    "check-ThreadedGB-3"

    # https://github.com/Macaulay2/M2/issues/1706
    "normal/command.m2"
    "normal/threads.m2"

    # FIXME: Times out, fails :(.
    "normal/gbf4.m2"

    # FIXME: Out of memory.
    "normal/release-checklist.m2"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "macaulay2";
      desktopName = "Macaulay2";
      exec = "M2";
      icon = "Macaulay2";
      comment = finalAttrs.meta.description;
      categories = [
        "Education"
        "Math"
        "ConsoleOnly"
      ];
      terminal = true;
    })
  ];

  postInstall = ''
    for sz in 64 72 96 128 192 256 512; do
      install -Dm644 ${macaulay2-icons}/NinePlanets-''${sz}x''${sz}.png $out/share/icons/hicolor/''${sz}x''${sz}/apps/Macaulay2.png
    done
  '';

  meta = {
    description = "Software system for algebraic geometry and commutative algebra";
    license = lib.licenses.gpl2Plus;
    homepage = "https://macaulay2.com/";
    mainProgram = "M2";
    platforms = lib.platforms.linux;
  };
})
