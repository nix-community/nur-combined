{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pythonOlder,
  hatchling,
}:
buildPythonPackage rec {
  pname = "sixelcrop";
  version = "0.1.9";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "joouha";
    repo = "sixelcrop";
    tag = "v${version}";
    hash = "sha256-oqTkMbpWIiUOKq5CwWRC4ZoeKun+FsjDGa5FkifFYCg=";
  };

  build-system = [hatchling];

  pythonImportsCheck = [
    "sixelcrop"
  ];

  meta = with lib; {
    description = "A library for cropping sixel images";
    homepage = "https://github.com/joouha/sixelcrop";
    license = licenses.mit;
    maintainers = with maintainers; [renesat];
  };
}
