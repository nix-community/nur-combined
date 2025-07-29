{
  lib,
  stdenv,
  libffi,
  pkg-config,
  pycparser,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  wheel,
  pythonOlder,
}:
let
  # CFFI pinned to 1.15.1
  # Derivation is taken from nixpkgs as of 3 years ago
  cffi-1-15 = buildPythonPackage rec {
    pname = "cffi";
    version = "1.15.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-1AC/uaN7E1ElPLQCZxzqfom97MKU6AFqcH9tHYrJNPk=";
    };

    pyproject = true;
    build-system = [ setuptools ];

    outputs = [
      "out"
      "dev"
    ];

    buildInputs = [ libffi ];

    nativeBuildInputs = [ pkg-config ];

    propagatedBuildInputs = [ pycparser ];

    postPatch = lib.optionalString stdenv.isDarwin ''
      # Remove setup.py impurities
      substituteInPlace setup.py \
        --replace "'-iwithsysroot/usr/include/ffi'" "" \
        --replace "'/usr/include/ffi'," "" \
        --replace '/usr/include/libffi' '${lib.getDev libffi}/include'
    '';

    # The tests use -Werror but with python3.6 clang detects some unreachable code.
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-unused-command-line-argument -Wno-unreachable-code -Wno-c++11-narrowing";

    # Can't figure out how to make the tests pass
    doCheck = false;

    meta = with lib; {
      maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
      homepage = "https://cffi.readthedocs.org/";
      license = licenses.mit;
      description = "Foreign Function Interface for Python calling C code";
    };
  };
in
buildPythonPackage rec {
  pname = "mip";
  version = "1.15.0";

  disabled = pythonOlder "3.7" || !(pythonOlder "3.12");

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-f28Dgc/ixSwbhkAgPaLLVpdLJuI5UN37GnazfZFvGX4=";
  };

  propagatedBuildInputs = [
    setuptools
    setuptools-scm
    cffi-1-15
  ];

  pythonImportsCheck = [
    "mip"
  ];

  pyproject = true;
  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  meta = {
    description = "Python-MIP: collection of Python tools for the modeling and solution of Mixed-Integer Linear programs ";
    homepage = "https://python-mip.com/";
    license = lib.licenses.epl20;
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
  };
}
