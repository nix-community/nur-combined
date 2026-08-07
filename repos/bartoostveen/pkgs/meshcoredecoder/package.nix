{
  lib,
  python314Packages,
  nix-update-script,
}:

let
  pythonPackages = python314Packages;
in
pythonPackages.buildPythonPackage (finalAttrs: {
  pname = "meshcoredecoder";
  version = "0.3.2";
  pyproject = true;

  __structuredAttrs = true;
  strictDeps = true;

  src = pythonPackages.fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-QF0FZzU5HZ62maUm1sQtT9QglNVUf94ivBLbXUVEqQQ=";
  };

  build-system = with pythonPackages; [
    setuptools
  ];

  dependencies = with pythonPackages; [
    click
    cryptography
    pycryptodome
    wheel
  ];

  optional-dependencies = with pythonPackages; {
    dev = [
      black
      pylint
      pytest
      pytest-cov
    ];
  };

  pythonImportsCheck = [
    "meshcoredecoder"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Complete Python implementation of the MeshCore Packet Decoder";
    homepage = "https://pypi.org/project/meshcoredecoder/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
