{ maintainers, pkgs, ... }:
let
  pname = "pywellen-mcp";
  version = "0.8.0";
  pythonEnv = pkgs.python312Packages;
in
pythonEnv.buildPythonApplication {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "fvutils";
    repo = "pywellen-mcp";
    rev = "60eb5d54fa2a8dfad02f27463a82896b7f26e01e";
    hash = "sha256-5UVChofr0gvP14xpvQyjqRosYHuODxVU5uM8HcqbRxY=";
  };

  format = "pyproject";

  propagatedBuildInputs = with pythonEnv; [
    mcp
    pydantic
  ];

  nativeBuildInputs = with pythonEnv; [
    setuptools
  ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "MCP server for waveform analysis - VCD, FST, GHW support with LLM integration";
    homepage = "https://github.com/fvutils/pywellen-mcp";
    license = licenses.asl20;
    mainProgram = pname;
    maintainers = with maintainers; [ srcres258 ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
