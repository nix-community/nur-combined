{
  pkgs,
  python3,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-jupyter";
  version = "0.3.0";
  src = pkgs.fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-jupyter";
    rev = "8b3b29312e0fea6259a6fd4f35ecd00c5efa5e8b";
    sha256 = "sha256-2+N6bEXcZfviGNf20VJOPdh/L8kDeSktvnKMuQEo37U=";
  };

  doCheck = false;

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
  ];

  meta = {
    homepage = "https://github.com/xonsh/xontrib-jupyter";
    license = ''
      MIT
    '';
    description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) [how-to](https://github.com/drmikecrowe/nur-packages) xonsh direnv";
  };
}
