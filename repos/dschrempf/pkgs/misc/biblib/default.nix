{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "biblib";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "colour-science";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-muT0qmBuvmfQYraPSM3IwmYJhkdsrku48lHewWiHsRg=";
  };

  meta = with lib; {
    description = "Parser for BibTeX bibliographic databases";
    homepage = "https://github.com/colour-science/biblib";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
