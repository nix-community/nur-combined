{
  lib,
  buildPythonPackage,
  fetchFromGitea,
  poetry-core,
  lxmf,
}:

buildPythonPackage (finalAttrs: {
  pname = "lxmfy";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitea {
    domain = "git.quad4.io";
    owner = "LXMFy";
    repo = "LXMFy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U2lHMsi4/SaTs+qeY4HGa7XDGOsPjlVaK6mzFxopSEY=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    lxmf
  ];

  pythonImportsCheck = [ "lxmfy" ];

  meta = {
    description = "LXMF bot framework";
    homepage = "https://git.quad4.io/LXMFy/LXMFy";
    changelog = "https://git.quad4.io/LXMFy/LXMFy/raw/tag/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "lxmfy";
  };
})
