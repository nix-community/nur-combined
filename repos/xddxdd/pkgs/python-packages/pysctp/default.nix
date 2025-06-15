{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  setuptools,
  lksctp-tools,
}:
buildPythonPackage rec {
  inherit (sources.pysctp) pname version src;

  build-system = [ setuptools ];
  buildInputs = [
    lksctp-tools
  ];

  pythonImportsCheck = [ "sctp" ];

  meta = {
    changelog = "https://github.com/p1sec/pysctp/releases/tag/${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "SCTP stack for Python";
    homepage = "https://github.com/p1sec/pysctp";
    license = with lib.licenses; [ lgpl2Only ];
  };
}
