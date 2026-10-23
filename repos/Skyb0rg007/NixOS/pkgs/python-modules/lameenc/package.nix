{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  lame,
  nix-update-script,
}:
buildPythonPackage (finalAttrs: {
  pname = "lameenc";
  version = "1.9.0";
  __structuredAttrs = true;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrisstaite";
    repo = "lameenc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JR2eqg/kO1n4ORWEZy6Ak8qSR1e/baNCyyEOE3NgEMY=";
  };

  # Link the shared LAME instead of a static one passed via --libdir/--incdir.
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "if 'bdist_wheel' in sys.argv:" "if False:" \
      --replace-fail "include_dirs=[incdir] if incdir else []" \
        "include_dirs=['${lib.getDev lame}/include/lame']" \
      --replace-fail "libraries=['libmp3lame'] if sys.platform == 'win32' else []" \
        "libraries=['mp3lame']"
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  buildInputs = [ lame ];

  pythonImportsCheck = [ "lameenc" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python bindings for the LAME MP3 encoder";
    homepage = "https://github.com/chrisstaite/lameenc";
    changelog = "https://github.com/chrisstaite/lameenc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
