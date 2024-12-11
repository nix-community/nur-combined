{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  baize,
  pdm-pep517,
  pydantic,
  typing-extensions,
}:
buildPythonPackage rec {
  inherit (sources.kui) pname version src;
  pyproject = true;

  propagatedBuildInputs = [
    baize
    pdm-pep517
    pydantic
    typing-extensions
  ];

  pythonImportsCheck = [ "kui" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Easy-to-use web framework";
    homepage = "https://kui.aber.sh/";
    license = with lib.licenses; [ asl20 ];
  };
}
