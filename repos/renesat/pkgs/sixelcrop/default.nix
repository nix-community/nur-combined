{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
}:
buildPythonPackage rec {
  pname = "sixelcrop";
  version = "0.1.8";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "joouha";
    repo = "sixelcrop";
    rev = "v${version}";
    hash = "sha256-Q+gQefnTXyf6qktRvxfvsf32dQXDsn8e6nSmiKTlMgw=";
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
