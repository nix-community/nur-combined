{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  python-dotenv,
}:
buildPythonPackage rec {
  inherit (sources.rootutils) pname version src;

  propagatedBuildInputs = [
    python-dotenv
  ];

  pythonImportsCheck = [ "rootutils" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Simple python package to solve all your problems with pythonpath, work dir, file paths, module imports and environment variables";
    homepage = "https://pypi.org/project/rootutils/";
    license = with lib.licenses; [ mit ];
  };
}
