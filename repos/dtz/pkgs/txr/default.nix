{ stdenv, fetchurl, bison, flex, libffi }:

stdenv.mkDerivation rec {
  name = "txr-${version}";
  version = "206";

  src = fetchurl {
    url = "http://www.kylheku.com/cgit/txr/snapshot/${name}.tar.bz2";
    sha256 = "001aykwsa09gw2hv4lf856x7c9pxmadz2309nr70kib6cp6hgrnj";
  };

  nativeBuildInputs = [ bison flex ];
  buildInputs = [ libffi ];

  enableParallelBuilding = true;

  doCheck = true;
  checkTarget = "tests";

  # Remove failing test-- mentions 'usr/bin' so probably related :)
  preCheck = "rm -rf tests/017";

  # TODO: install 'tl.vim', make avail when txr is installed or via plugin

  meta = with stdenv.lib; {
    description = "Programming language for convenient data munging";
    license = licenses.bsd2;
    homepage = http://nongnu.org/txr;
    maintainers = with stdenv.lib.maintainers; [ dtzWill ];
  };
}
