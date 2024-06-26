{
  pkgs,
  python3,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-jedi";
  version = "0.0.2";
  src = pkgs.fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-jedi";
    rev = "10c6ee341f65812a06145d097b06ace8bc2cf154";
    sha256 = "sha256-cVlom9Ez3kxZTgm3dWfAJQ+DdhuACM76p6NvbyPrLyc=";
  };

  doCheck = false;

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
  ];

  meta = {
    homepage = "https://github.com/xonsh/xontrib-jedi";
    license = ''
      MIT
    '';
    description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) [how-to](https://github.com/drmikecrowe/nur-packages) xonsh direnv";
  };
}
