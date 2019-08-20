{ buildPythonPackage, stdenv, python, fetchFromGitHub,
  pyopenssl, typing, webcolors, future, atomicwrites,
  attrs, Logbook, pygments, cachetools, matrix-nio }:

buildPythonPackage {
  pname = "weechat-matrix";
  version = "git";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "weechat-matrix";
    rev = "dc97101d47187f15e106579200ad0d17e9e67192";
    sha256 = "19294nzvk4vxj8zna9vrqbyg2swyighqvfja4kknj3i1d9szdy3p";
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
  
    mkdir -p $out/lib/python2.7/site-packages
    cp -r $src/matrix $out/lib/python2.7/site-packages/matrix
  '';

  doCheck = false;
}
