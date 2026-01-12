{
  maintainers,
  pkgs,
  ...
}: let
  python = pkgs.python312;
  pythonEnv = pkgs.python312Packages;

  pname = "ag";
  version = "0.1.2";
in pythonEnv.buildPythonApplication {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = "ag";
    rev = "v0.1.2";
    sha256 = "sha256-rKsddgwhzZEQeXgWfJ2oOvSMYdlol+Vm4UKMG+Ieb+s=";
  };

  propagatedBuildInputs = with pythonEnv; [
    openai
    termcolor
    prompt-toolkit
  ];
  nativeBuildInputs = with pythonEnv; [
    hatchling
  ];

  format = "pyproject";

  doCheck = true;

  meta = with pkgs.lib; {
    description = "A command-line AI assistant";
    homepage = "https://github.com/srcres258/ag";
    license = licenses.mit;
    maintainers = with maintainers; [ srcres258 ];
    platforms = platforms.linux;
    mainProgram = pname;
  };
}
