{ buildPythonPackage, stdenv, python, fetchFromGitHub,
  pyopenssl, typing, webcolors, future, atomicwrites,
  attrs, Logbook, pygments, cachetools, matrix-nio }:

buildPythonPackage {
  pname = "weechat-matrix";
  version = "git";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "weechat-matrix";
    rev = "f5f08cba6f63959756c1dd1b5d18eaa33450127b";
    sha256 = "0429w8wrz7rlvy5jczaygm13dqli5357sbrqfi70jqs00js5msc8";
  };

  propagatedBuildInputs = [
    pyopenssl
    typing
    webcolors
    future
    atomicwrites
    attrs
    Logbook
    pygments
    cachetools
    matrix-nio
  ];

  passthru.scripts = [ "matrix.py" ];

  buildPhase = ":";

  installPhase = ''
    mkdir -p $out/share
    cp $src/main.py $out/share/matrix.py
    # cp -r $src/matrix $out/share/
  
    mkdir -p $out/lib/${python.libPrefix}/site-packages
    cp -r $src/matrix $out/lib/${python.libPrefix}/site-packages/matrix
  '';

  doCheck = false;
}
