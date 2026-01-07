{
  maintainers,
  pkgs,
  ...
}: let
  python = pkgs.python312;
  pythonEnv = pkgs.python312Packages;

  pname = "ag";
  version = "0.1.0";
in pythonEnv.buildPythonApplication {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = "ag";
    rev = "cf6c2b8777b5e9436ce13f2a676d59f52e0e1c66";
    sha256 = "sha256-+t8Ei7hnAnzxACY25yHNGRA40/IjB8bgABXws4/5jtY=";
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
