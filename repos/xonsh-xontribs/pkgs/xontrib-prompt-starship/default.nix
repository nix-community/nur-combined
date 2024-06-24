{
  pkgs,
  python3,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-prompt-starship";
  version = "0.3.6";
  src = pkgs.fetchFromGitHub {
    owner = "anki-code";
    repo = "xontrib-prompt-starship";
    rev = "d7603433bdb858ef8e38580247f099ac82d2660c";
    sha256 = "sha256-CLOvMa3L4XnH53H/k6/1W9URrPakPjbX1T1U43+eSR0=";
  };

  doCheck = false;

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
  ];

  meta = {
    homepage = "https://github.com/anki-code/xontrib-prompt-starship";
    license = ''
      MIT
    '';
    description = "xonsh starship xontrib";
  };
}
