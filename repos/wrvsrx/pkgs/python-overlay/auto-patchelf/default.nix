{
  buildPythonPackage,
  pythonOlder,
  hatchling,
  pyelftools,
  source,
}:

buildPythonPackage {
  inherit (source) pname src version;
  pyproject = true;

  disabled = pythonOlder "3.12";

  build-system = [ hatchling ];

  dependencies = [
    pyelftools
  ];

}
