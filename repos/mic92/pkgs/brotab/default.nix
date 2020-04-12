{ stdenv, python3, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "brotab";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "balta2ar";
    repo = "brotab";
    rev = "${version}";
    sha256 = "17yj5i8p28a7zmixdfa1i4gfc7c2fmdkxlymazasar58dz8m68mw";
  };

  propagatedBuildInputs = [ requests psutil flask ipython ];
  checkInputs = [ pytest ];

  meta = with stdenv.lib; {
    description = "Control your browser's tabs from the command line";
    homepage = "https://github.com/balta2ar/brotab";
    license = licenses.mit;
  };
}
