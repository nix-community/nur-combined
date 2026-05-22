{
  lib,
  fetchFromGitHub,
  python3Packages,
  maintainers,
  ...
}:
let
  pname = "tbc-video-export";
  version = "0.1.8";

  rev = "v${version}";
  hash = "sha256-PN365f6OIe9h4ffLhon+rNBIAC1QeLiEr3wQvloQml0=";
in
python3Packages.buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "JuniorIsAJitterbug";
    repo = "tbc-video-export";
  };

  format = "pyproject";

  buildInputs = [
    python3Packages.poetry-core
    python3Packages.poetry-dynamic-versioning
  ];

  propagatedBuildInputs = [
    python3Packages.typing-extensions
  ];

  meta = {
    inherit maintainers;
    description = "Tool for exporting S-Video and CVBS-type TBCs to video files.";
    homepage = "https://github.com/JuniorIsAJitterbug/tbc-video-export";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
