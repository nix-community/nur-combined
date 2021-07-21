{ lib
, python
, buildPythonPackage
, fetchPypi
, pythonOlder
, swig
, ncurses
, blas
, lapack
, pyaudio
}:

buildPythonPackage rec {
  pname = "snowboy";
  version = "1.2.0b1";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-sF832QYW5h3hl8FtAtUgVkezlup0SASDe1bDOjRWncQ=";
  };

  preBuild = ''
    rm ./swig/Python/snowboy-detect-swig.o
    sed -i -e 's!-llapack_atlas -latlas!!' swig/Python/Makefile
    sed -i -e 's!-lf77blas!!' swig/Python/Makefile
  '';

  postInstall = ''
    ln -s $out/${python.sitePackages}/snowboy/snowboydetect.py $out/${python.sitePackages}/
    ln -s $out/${python.sitePackages}/snowboy/_snowboydetect.so $out/${python.sitePackages}/
  '';

  buildInputs = [
    ncurses
    blas
    lapack
  ];

  propagatedBuildInputs = [
    pyaudio
  ];

  nativeBuildInputs = [
    swig
  ];

  meta = with lib; {
    description = "Customizable hotword detection engine";
    homepage = "https://pypi.org/project/snowboy";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
