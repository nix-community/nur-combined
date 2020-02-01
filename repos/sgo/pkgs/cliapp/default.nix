{ stdenv
, python3
, python3Packages
, fetchgit
}:

python3.pkgs.buildPythonPackage rec {
  pname = "cliapp";
  version = "1.20180812.1";

  src = fetchgit {
    url = "git://git.liw.fi/cliapp/";
    rev = "refs/tags/${pname}-${version}";
    sha256 = "0chz4ys4r5qffflnix72rlvca8l0g4hghlsicis70ydq91sgfhfa";
  };


  propagatedBuildInputs = with python3Packages; [ sphinx pyyaml ];

  # error: invalid command 'test'
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = http://liw.fi/cliapp/;
    description = "Python framework for Unix command line programs";
    license = licenses.gpl2;
    maintainers = [];
  };


}
