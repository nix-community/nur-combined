{ lib, buildPythonPackage, fetchFromGitHub, setuptools, torch, numpy, scipy, matplotlib, astropy, torchdiffeq, mhealpy }:

buildPythonPackage rec {
  pname = "jammy-flows";
  version = "1.1.0-unstable-2026-07-22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "thoglu";
    repo = "jammy_flows";
    rev = "cd400da11e4ecf3a34b92b5eb04bd8094efc045a";
    hash = "sha256-1HY+NK1UbuD5BKET7TZAI/i/qcDepTxP5K/bfQ//LvI=";
  };

  build-system = [ setuptools ];
  dependencies = [ torch numpy scipy matplotlib astropy torchdiffeq mhealpy ];
  pythonImportsCheck = [ "jammy_flows" ];

  meta = {
    description = "Normalizing flow PDFs on products of manifolds";
    homepage = "https://github.com/thoglu/jammy_flows";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
