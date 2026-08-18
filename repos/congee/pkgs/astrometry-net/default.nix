{
  lib,
  stdenv,
  fetchFromGitHub,
  fixDarwinDylibNames,
  makeWrapper,
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
  # nixpkgs wcslib has a bare dylib install id, unresolvable at runtime on darwin.
  wcslib' =
    if stdenv.hostPlatform.isDarwin then
      wcslib.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ fixDarwinDylibNames ];
      })
    else
      wcslib;

  # augment-xylist shells out to removelines/uniformize on every solve and exits
  # if one fails. They are python: numpy, plus astropy for astrometry.util.fits.
  pythonEnv = python3.withPackages (ps: [
    ps.numpy
    ps.astropy
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "astrometry-net";
  version = "0.98";

  # Tag, not release tarball: upstream tags ahead of publishing. The tarball only
  # adds pre-swigged sources (`all` never swigs) and a `git describe`, pinned below.
  src = fetchFromGitHub {
    owner = "dstndstn";
    repo = "astrometry.net";
    tag = finalAttrs.version;
    hash = "sha256-/YLDcPOQHw23s77s3XRVa6YV4CwT5CKs3f+m2pBLajY=";
  };

  # pythonEnv is also a runtime dep (see above).
  nativeBuildInputs = [
    makeWrapper
    pkg-config
    pythonEnv
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

  # Stop install targets from building unused swig bindings; the tracebacks are
  # ignored but noisy. `:` swallows the rest of the recipe line.
  postPatch = ''
    substituteInPlace sdss/Makefile \
      --replace-fail 'all: try_lib' 'all:' \
      --replace-fail '@echo "Trying to build (optional) python module..."' ':' \
      --replace-fail '-$(MAKE) lib &&' ':'
    substituteInPlace libkd/Makefile \
      --replace-fail '-$(MAKE) install-spherematch' ':'
    substituteInPlace util/Makefile \
      --replace-fail '@echo "The following copy commands may fail; they are optional."' ':' \
      --replace-fail '-$(MAKE) py &&' ':'
    # `install-extra` installs the cairo binaries, then tries the bindings.
    substituteInPlace solver/Makefile plot/Makefile \
      --replace-fail 'PYTHON_EXTRA_INSTALL :=' 'PYTHON_EXTRA_INSTALL := #' \
      --replace-fail '$(MAKE) $(PYTHON_EXTRA_INSTALL)' ':'

    # Pre-create so `make report` (host probing) never runs.
    touch report.txt
  '';

  # Upstream Makefile is not parallel-safe.
  enableParallelBuilding = false;

  # No ./configure; the Makefile's `config` target runs as part of `make`.
  dontConfigure = true;

  makeFlags = [
    "INSTALL_DIR=${placeholder "out"}"
    # Baked into binaries and FITS headers; no .git here, so pin them instead of
    # letting the `git: command not found` fallback bake in empty strings.
    "AN_GIT_REVISION=${finalAttrs.version}"
    "AN_GIT_DATE=unknown"
    # Release-only, but `:=` expands it on every top-level Makefile parse.
    "RELEASE_VER=${finalAttrs.version}"
    # Shebang for the installed helpers; upstream default is /usr/bin/env.
    "PYTHON_SCRIPT=${pythonEnv}/bin/python3"
    "SYSTEM_GSL=yes"
    "NETPBM_INC=-I${lib.getDev netpbm}/include/netpbm" # netpbm has no .pc file
    "NETPBM_LIB=-L${lib.getLib netpbm}/lib -lnetpbm"
  ];

  # `all` skips `make py` (swig bindings), which nothing here needs.
  buildFlags = [ "all" ];
  installTargets = [ "install" ];

  postInstall = ''
    # Drop the postPatch stub.
    find "$out" -name report.txt -delete

    # Non-FITS input shells out to netpbm (jpegtopnm, pnmfile, ...). solve-field
    # calls augment_xylist() in-process, so its PATH covers the whole chain.
    for b in solve-field augment-xylist image2pnm; do
      wrapProgram "$out/bin/$b" --prefix PATH : ${lib.makeBinPath [ netpbm ]}
    done
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    for b in solve-field astrometry-engine image2xy image2pnm wcsinfo build-astrometry-index; do
      test -x "$out/bin/$b" || { echo "missing expected binary: $out/bin/$b"; exit 1; }
    done
    "$out/bin/solve-field" --help > /dev/null

    # `test -x` passes on a dead shebang, so actually run the solve helpers.
    "$out/bin/removelines" "$out/examples/apod1.xyls" removelines.xyls
    "$out/bin/uniformize" -n 10 removelines.xyls uniformize.xyls
    test -s uniformize.xyls

    # Covers the shebang and the wrapped netpbm PATH.
    "$out/bin/image2pnm" --infile "$out/examples/apod1.jpg" --outfile apod1.pnm
    test -s apod1.pnm
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
