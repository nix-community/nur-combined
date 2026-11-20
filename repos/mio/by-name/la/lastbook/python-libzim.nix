{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  cython,
  libzim,
}:

# Lastbook reads offline ZIM encyclopedias through these bindings. It pins the
# PyPI version whose C++ side matches nixpkgs' libzim (9.8.2).
buildPythonPackage (finalAttrs: {
  pname = "libzim";
  version = "3.13.1";
  format = "setuptools";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Rt2A5d6hTxT13OqBNZifIw5Hc6jLJv1jL7d1bFObZRY=";
  };

  # Upstream downloads a prebuilt libzim unless USE_SYSTEM_LIBZIM is set, and
  # then probes for it with ctypes' find_library, which cannot see the store.
  env = {
    USE_SYSTEM_LIBZIM = "1";
    NIX_CFLAGS_COMPILE = "-I${lib.getDev libzim}/include";
    NIX_LDFLAGS = "-L${lib.getLib libzim}/lib";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "if not config.found_libzim:" "if False:"
  '';

  build-system = [
    setuptools
    wheel
    cython
  ];

  buildInputs = [ libzim ];

  doCheck = false;

  meta = {
    description = "Python bindings for libzim (ZIM file reader)";
    homepage = "https://github.com/openzim/python-libzim";
    license = lib.licenses.gpl3Plus;
  };
})
