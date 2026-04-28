{
  maintainers,
  pkgs,
  ...
}: let
  python = pkgs.python312;
  pythonEnv = pkgs.python312Packages;

  pname = "adif-manage";
  version = "0.2.0";
in pythonEnv.buildPythonApplication {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = pname;
    rev = "v0.2.0";
    sha256 = "sha256-8OXAgIgeFkmST9GexiFVmG8lcNRcMI660SV4L4zgobQ=";
  };

  propagatedBuildInputs = with pythonEnv; [
    prompt-toolkit
  ];
  nativeBuildInputs = with pythonEnv; [
    hatchling
  ];

  format = "pyproject";

  meta = with pkgs.lib; {
    description = "ADIF ham log management program";
    homepage = "https://github.com/srcres258/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ srcres258 ];
    platforms = platforms.linux;
    mainProgram = pname;
  };
}
