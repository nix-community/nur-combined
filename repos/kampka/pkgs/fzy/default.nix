{ stdenv, buildPackages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "1.0";
  name = "fzy-${version}";

  src = fetchFromGitHub {
    owner = "jhawthorn";
    repo = "fzy";
    rev = "${version}";
    sha256 = "1gkzdvj73f71388jvym47075l9zw61v6l8wdv2lnc0mns6dxig0k";
  };

  preConfigure = ''
    export PREFIX="$out"
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/jhawthorn/fzy;
    license = licenses.mit;
    description = "A better fuzzy finder";
    platforms = platforms.unix;
  };
}
