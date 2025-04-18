{
  buildPythonPackage,
  pythonOlder,
  hatchling,
  pyelftools,
  source,
}:

buildPythonPackage {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  pyproject = true;

  disabled = pythonOlder "3.12";

  build-system = [ hatchling ];

  dependencies = [
    pyelftools
  ];

}
