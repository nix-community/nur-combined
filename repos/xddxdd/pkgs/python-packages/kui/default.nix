{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  baize,
  nix-update-script,
  pdm-pep517,
  pydantic,
  typing-extensions,
}:
buildPythonPackage (finalAttrs: {
  pname = "kui";
  version = "1.14.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "abersheeran";
    repo = "kui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PbE90v7y5qzyNJCCh8759BDPq2nFKO7A2FchIbHYWxk=";
  };
  propagatedBuildInputs = [
    baize
    pdm-pep517
    pydantic
    typing-extensions
  ];

  pythonImportsCheck = [ "kui" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Easy-to-use web framework";
    homepage = "https://kui.aber.sh/";
    license = with lib.licenses; [ asl20 ];
    # FIXME: dependency package baize is broken
    broken = true;
  };
})
