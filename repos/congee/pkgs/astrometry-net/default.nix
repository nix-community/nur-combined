{
  lib,
  stdenv,
  fetchurl,
  fixDarwinDylibNames,
  pkg-config,
  python3,
  cairo,
  cfitsio,
  gsl,
  libjpeg,
  libpng,
  netpbm,
  wcslib,
  zlib,
  bzip2,
}:

let
  # nixpkgs wcslib ships its dylib with a bare install id ("libwcs.8.dylib"),
  # so binaries linking it can't find it at runtime on darwin. Rewrite the id.
  wcslib' =
    if stdenv.hostPlatform.isDarwin then
      wcslib.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ fixDarwinDylibNames ];
      })
    else
      wcslib;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "astrometry-net";
  version = "0.97";

  # The release tarball bakes the version into makefile.common and ships
  # pre-swigged sources (no swig/git needed). Releases stop at 0.97.
  src = fetchurl {
    url = "https://github.com/dstndstn/astrometry.net/releases/download/${finalAttrs.version}/astrometry.net-${finalAttrs.version}.tar.gz";
    hash = "sha256-5O7xtli6WtRiKCtmHAyjpcU4uhcW6FP3lwt7n6SjNFk=";
  };

  # python3: build-time only (generates etc/astrometry.cfg); report.txt, its
  # only runtime-closure reference, is removed below.
  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    cairo
    cfitsio
    gsl
    libjpeg
    libpng
    netpbm
    wcslib'
    zlib
    bzip2
  ];

  # Upstream Makefile is not parallel-safe.
  enableParallelBuilding = false;

  # No ./configure; the Makefile's `config` target runs as part of `make`.
  dontConfigure = true;

  makeFlags = [
    "INSTALL_DIR=${placeholder "out"}"
    "AN_GIT_REVISION=${finalAttrs.version}" # avoid `git describe` (no .git here)
    "SYSTEM_GSL=yes"
    "NETPBM_INC=-I${lib.getDev netpbm}/include/netpbm" # netpbm has no .pc file
    "NETPBM_LIB=-L${lib.getLib netpbm}/lib -lnetpbm"
  ];

  # siril only needs the C solver, so skip `make py` (numpy/swig bindings).
  buildFlags = [ "all" ];
  installTargets = [ "install" ];

  # report.txt just records the build environment and drags python3 into the
  # closure by mentioning its path; drop it (upstream Homebrew does the same).
  postInstall = ''
    find "$out" -name report.txt -delete
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    for b in solve-field astrometry-engine image2xy image2pnm wcsinfo build-astrometry-index; do
      test -x "$out/bin/$b" || { echo "missing expected binary: $out/bin/$b"; exit 1; }
    done
    "$out/bin/solve-field" --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    homepage = "https://astrometry.net/";
    description = "Automatic astrometric calibration — blind plate solver (solve-field)";
    longDescription = ''
      Command-line tools (solve-field, astrometry-engine, ...) that identify an
      astronomical image and compute its WCS. Solving also requires index files
      matched to the field of view, downloaded separately and referenced from an
      astrometry.cfg.
    '';
    license = lib.licenses.bsd3;
    mainProgram = "solve-field";
    maintainers = with lib.maintainers; [ congee ];
    platforms = lib.platforms.unix;
  };
})
