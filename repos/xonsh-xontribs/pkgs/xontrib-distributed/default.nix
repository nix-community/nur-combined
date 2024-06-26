{
  pkgs,
  python3,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-distributed";
  version = "0.0.4";
  src = pkgs.fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-distributed";
    rev = "91420b6819dda54ee8cc445beb41c1401ce053a9";
    sha256 = "sha256-/r9BNUaMMEtMzLNpeYjhlrrsNJJXCVTHsWsIYStDFA8=";
  };

  doCheck = false;

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
  ];

  meta = {
    homepage = "https://github.com/xonsh/xontrib-distributed";
    license = ''
      MIT
    '';
    description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) [how-to](https://github.com/drmikecrowe/nur-packages) xonsh direnv";
  };
}
