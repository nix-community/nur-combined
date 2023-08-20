{ lib
, buildPythonPackage
, buildPythonApplication
, fetchFromGitHub
, fetchurl
, fetchPypi
, python3
, python311
}:

let

  # TODO move to pkgs/python3/pkgs
  htmldata = buildPythonPackage rec {
    pname = "htmldata";
    version = "1.1.1";
    # https://web.archive.org/web/20080820063040/http://www.connellybarnes.com/code/htmldata/
    # https://github.com/milahu/htmldata
    src = fetchFromGitHub {
      owner = "milahu";
      repo = "htmldata";
      rev = "d85467f95d1cd4b2172f755b5231b547d8117e18";
      sha256 = "sha256-5S1OTkpIHKJPtN3TrKfUJeFjCrDG5I2ltckDT98QUIo=";
    };
  };

in

buildPythonApplication rec {
  pname = "mediawiki2html";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    owner = "samuell";
    repo = "mw2html";
    rev = "805e19a7165c7fbf8cc96f07a3f5227df322bdaf";
    sha256 = "sha256-+h2IK1Vou0riw5MVqWTcWyzDugtuhj2mmG0WM9s0mf4=";
  };

  setup-py = ''
    from setuptools import setup, find_packages
    setup(
      name='mediawiki2html',
        version='${version}',
        packages=find_packages(),
        scripts=["mediawiki2html"],
    )
  '';

  postPatch = ''
    echo ${lib.escapeShellArg setup-py} >setup.py
    ${python311}/bin/2to3 -w -n --no-diffs .
    substituteInPlace mw2html.py \
      --replace "import sha" "import hashlib" \
      --replace "sha.new(str(random.random()))" "hashlib.sha1(str(random.random()).encode('ascii'))" \
      --replace "sha.new(tail)" "hashlib.sha1(tail.encode('utf8'))"
    mv mw2html.py mediawiki2html
    chmod +x mediawiki2html
  '';

  propagatedBuildInputs = [
    htmldata
  ];

  meta = with lib; {
    homepage = "https://github.com/samuell/mw2html";
    description = "scrape mediawiki pages to static html files";
    maintainers = [];
    license = licenses.publicDomain;
    platforms = platforms.all;
  };
}
