{
  maintainers,
  pkgs,
  ...
}: let
  python = pkgs.python312;
  pythonEnv = pkgs.python312Packages;

  pname = "jyyslide-util";
  version = "0.1.0";
in pythonEnv.buildPythonApplication {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-bPdkt5vvDt6F/oYNR4Gyl19Qq39ZJEXcly7zD9Agol4=";
  };

  propagatedBuildInputs = with pythonEnv; [
    jinja2
    pyquery
    pyyaml
    markdown
    requests
  ];
  nativeBuildInputs = with pythonEnv; [
    hatchling
    hatch-vcs
    setuptools-scm
  ];

  format = "pyproject";

  doCheck = true;

  meta = with pkgs.lib; {
    description = "A tool for creating jyy-style slides";
    homepage = "https://github.com/srcres258/${pname}";
    license = licenses.bsd3;
    maintainers = with maintainers; [ srcres258 ];
    platforms = platforms.linux;
    mainProgram = pname;
  };
}
