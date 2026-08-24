{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  nix-update-script,
  setuptools,
  lksctp-tools,
}:
buildPythonPackage (finalAttrs: {
  pname = "pysctp";
  version = "0.7.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "p1sec";
    repo = "pysctp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CtWS+tuh2+Q9Hr64W6bsPE2v020BpnUJ5FDHblGCcYs=";
  };
  build-system = [ setuptools ];
  buildInputs = [
    lksctp-tools
  ];

  pythonImportsCheck = [ "sctp" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/p1sec/pysctp/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "SCTP stack for Python";
    homepage = "https://github.com/p1sec/pysctp";
    license = with lib.licenses; [ lgpl2Only ];
  };
})
