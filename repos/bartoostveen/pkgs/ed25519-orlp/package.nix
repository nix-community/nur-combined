{
  lib,
  python3Packages,
  fetchPypi,
  nix-update-script,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ed25519-orlp";
  version = "0.1.3";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchPypi {
    pname = "ed25519_orlp";
    inherit (finalAttrs) version;
    hash = "sha256-XfpS6PY2h/Ao7Q4/jis4W//SKmMMdAvmQtc6Uy0BN90=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  pythonImportsCheck = [
    "ed25519_orlp"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python wrapper around Orson Peters' Ed25519 implementation";
    homepage = "https://pypi.org/project/ed25519-orlp";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "ed25519-orlp";
  };
})
