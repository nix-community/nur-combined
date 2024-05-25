{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "tilelog";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "tilelog";
    rev = "v${version}";
    hash = "sha256-tSBawN8u3mw6sSVFUMT+qfjbhwPF+x3sYXpO18YUjpw=";
  };

  nativeBuildInputs = with python3Packages; [ flake8 ];

  propagatedBuildInputs = with python3Packages; [
    click
    publicsuffixlist
    pyathena
    pyarrow
  ];

  doCheck = false;

  meta = {
    description = "Tilelog is used to generate tile logs for the OSMF Standard map layer";
    inherit (src.meta) homepage;
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
