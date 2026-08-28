{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cython,
  libyaml,
  isPy27,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "PyYAML";
  version = "5.4.1.1";

  src = fetchFromGitHub {
    owner = "yaml";
    repo = "pyyaml";
    rev = finalAttrs.version;
    hash = "sha256-qLdAMqoyEXRIqcNuHBBtST8GWh5gmx5fBU/q3f4zaOw=";
  };

  nativeBuildInputs = [ cython ];

  buildInputs = [ libyaml ];

  checkPhase = ''
    runHook preCheck
    PYTHONPATH=""tests/lib":$PYTHONPATH" ${python.interpreter} -m test_all
    runHook postCheck
  '';

  pythonImportsCheck = [ "yaml" ];

  meta = with lib; {
    description = "The next generation YAML parser and emitter for Python";
    homepage = "https://github.com/yaml/pyyaml";
    license = licenses.mit;
  };
})
