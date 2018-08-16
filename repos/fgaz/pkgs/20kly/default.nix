{ stdenv, fetchurl, python2Packages }:

# Mostly needed for the wrapper
python2Packages.buildPythonApplication rec {
  name = "20kly-${version}";
  version = "1.4";

  src = fetchurl {
    url = "http://jwhitham.org.uk/20kly/lightyears-${version}.tar.bz2";
    sha256 = "13h73cmfjqkipffimfc4iv0hf89if490ng6vd6xf3wcalpgaim5d";
  };

  patchPhase = ''
    substituteInPlace lightyears \
      --replace \
        "LIGHTYEARS_DIR = \".\"" \
        "LIGHTYEARS_DIR = \"$out/share\""
  '';

  propagatedBuildInputs = with python2Packages; [ python pygame ];

  buildPhase = "python -O -m compileall .";

  # There are no tests. This is not a standard package.
  doCheck = false;

  installPhase = ''
    mkdir -p $out/share
    cp -r audio code data lightyears $out/share
    install -Dm755 lightyears $out/bin/lightyears
  '';

  meta = with stdenv.lib; {
    description = "A steampunk-themed strategy game where you have to manage a steam supply network";
    homepage = "http://jwhitham.org.uk/20kly/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ fgaz ];
  };
}
