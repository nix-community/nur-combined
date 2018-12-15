{ stdenv, fetchFromGitHub, python3Packages }:
python3Packages.buildPythonPackage rec {
  name = "hkp4py-${version}";
  version = "0.2.3.0";

  src = fetchFromGitHub {
    owner = "Selfnet";
    repo = "hkp4py";
    rev = "${version}";
    sha256 = "1xhp86zzi404mn22i7hbr4l8llhdxvs5fnc4bsl45hl0q78jdd3p";
  };

  propagatedBuildInputs = with python3Packages; [ requests ];

  checkInputs = with python3Packages; [ pylint autopep8 pep8 ];

  meta = with stdenv.lib; {
    description = "A Library to get GPG/PGP keys from a Keyserver";
    license = licenses.mit;
    homepage = https://github.com/Selfnet/hkp4py;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

