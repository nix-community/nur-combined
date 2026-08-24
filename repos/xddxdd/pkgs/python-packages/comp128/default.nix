{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  nix-update-script,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "comp128";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Takuto88";
    repo = "comp128-python";
    tag = finalAttrs.version;
    hash = "sha256-0y36/J7l/PpiG5claCJF5oCCcFB7BPUQvba+73+Jwzc=";
  };
  build-system = [ setuptools ];

  pythonImportsCheck = [ "comp128" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/Takuto88/comp128-python/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python implementation of the Comp128 v1-3 GSM authentication algorithms";
    homepage = "https://github.com/Takuto88/comp128-python";
    license = with lib.licenses; [ gpl2Only ];
  };
})
