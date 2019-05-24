{ stdenv, notmuch, pythonPackages }:
stdenv.mkDerivation rec {
  name = "notmuch-${pythonPackages.python.name}-${version}";
  version = notmuch.version;
  outputs = [ "out" ];
  buildInputs = with pythonPackages; [ sphinx python ];
  src = notmuch.src;
  phases = [ "unpackPhase" "buildPhase" "installPhase" "fixupPhase" ];
  buildPhase = ''
    cd bindings/python
    python setup.py build
    '';
  installPhase = ''
    python setup.py install --prefix=$out --optimize=1
    '';
}
