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
    rev = "f78ae776164f0fe186e7ada12eab1336068a1687"; # FIXME: no tag for 0.1.9
    # rev = "v${version}";
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
