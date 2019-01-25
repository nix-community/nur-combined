{ stdenv, fetchFromGitHub, python3Packages }:
python3Packages.buildPythonPackage rec {
  name = "cmakeconverter-${version}";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "algorys";
    repo = "cmakeconverter";
    rev = "v${version}";
    sha256 = "17bd34lcf628inlw7h5laj5gls2lrz4nzl1i8rqwxryj3icny6rc";
  };

  propagatedBuildInputs = with python3Packages; [ lxml colorama docopt ];

  meta = with stdenv.lib; {
    description = "Facilitate the conversion of Visual Studio to CMake projects";
    license = licenses.agpl3;
    homepage = https://github.com/algorys/cmakeconverter;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

