{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "opencc-python-reimplemented";
  version = "0-unstable-2023-02-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "yichen0831";
    repo = "opencc-python";
    rev = "b85452e384a3650109809fe5fefacb2ae4fe89d2";
    hash = "sha256-47BW23SmZcSfjrEhUd7hIUAt451Ci2n8MEMaL0ngb04=";
  };
  build-system = [ setuptools ];

  pythonImportsCheck = [ "opencc" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenCC made with Python";
    homepage = "https://github.com/yichen0831/opencc-python";
    license = with lib.licenses; [ asl20 ];
  };
})
