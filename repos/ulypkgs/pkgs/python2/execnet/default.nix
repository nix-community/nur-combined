{
  lib,
  buildPythonPackage,
  isPyPy,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
  apipkg,
}:

buildPythonPackage (finalAttrs: {
  pname = "execnet";
  version = "1.9.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-j2lPO6nMksq1CLFS3P4yIVOXXCm9onLi/X8/APNuR8U=";
  };

  checkInputs = [ pytestCheckHook ];
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ apipkg ];

  # remove vbox tests
  postPatch = ''
    rm -v testing/test_termination.py
    rm -v testing/test_channel.py
    rm -v testing/test_xspec.py
    rm -v testing/test_gateway.py
    ${lib.optionalString isPyPy "rm -v testing/test_multi.py"}
  '';

  pythonImportsCheck = [ "execnet" ];

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "Distributed Python deployment and communication";
    license = licenses.mit;
    homepage = "https://execnet.readthedocs.io/";
    maintainers = with maintainers; [ ];
  };

})
