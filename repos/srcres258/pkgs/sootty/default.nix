{
  maintainers,
  pkgs,
  ...
}: let
  python = pkgs.python312;
  pythonEnv = pkgs.python312Packages;

  pname = "sootty";
  version = "1.1.0";
in pythonEnv.buildPythonApplication {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-hjgYo12vCyqQLiYNFmatAC0gutjfNjdKtPlIqzdA7Xo=";
  };

  format = "setuptools";

  propagatedBuildInputs = with pythonEnv; [
    lark
    pyyaml
    sortedcontainers
    pyvcd
  ];

  meta = with pkgs.lib; {
    description = "Graphical command-line waveform viewer for VCD/EVCD/FST files";
    homepage = "https://github.com/Ben1152000/sootty";
    license = licenses.bsd3;
    maintainers = with maintainers; [ srcres258 ];
    mainProgram = pname;
    platforms = platforms.linux;
  };
}
