{
  pkgs,
  python3,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-sh";
  version = "0.3.1";
  src = pkgs.fetchFromGitHub {
    owner = "anki-code";
    repo = "xontrib-sh";
    rev = "a8f54908d001336cf7580f36233aa8f00978b479";
    sha256 = "sha256-KL/AxcsvjxqxvjDlf1axitgME3T+iyuW6OFb1foRzN8=";
  };

  doCheck = false;

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
  ];

  meta = {
    homepage = "https://github.com/anki-code/xontrib-sh";
    license = ''
      BSD
    '';
    description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) [how-to](https://github.com/drmikecrowe/nur-packages) xonsh direnv";
  };
}
