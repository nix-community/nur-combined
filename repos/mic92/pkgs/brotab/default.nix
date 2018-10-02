{ stdenv, python3, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "brotab";
  version = "2018-09-14";

  src = fetchFromGitHub {
    owner = "balta2ar";
    repo = "brotab";
    rev = "f93626aaf460b9e63979e452346c340b91fd5934";
    sha256 = "014slk92687f226vkgsr9pl5x7gs7y6ljbid90dw3p5kw014dqxy";
  };

  propagatedBuildInputs = [ requests psutil flask ipython ];
  checkInputs = [ pytest ];

  meta = with stdenv.lib; {
    description = "Control your browser's tabs from the command line";
    homepage = https://github.com/balta2ar/brotab;
    license = licenses.mit;
  };
}
