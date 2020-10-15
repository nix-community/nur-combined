{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, iptables, libpcap, libxslt, libnl }:

stdenv.mkDerivation rec {
  version = "unstable-2020-05-25";
  pname = "nsntrace";

  src = fetchFromGitHub {
    owner = "nsntrace";
    repo = "nsntrace";
    rev = "35e174dec47f5806300313d43221fd3e128a109f";
    sha256 = "1650h49gr8dn2z9m7cglg8whvyc7isf071aqbxz2zxlq432858y7";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ iptables libnl libpcap libxslt ];

  #very ugly for now
  preConfigure = ''
    ./autogen.sh
    sed -i "/PKG_CHECK_MODULES.*/,/,:./d" configure
    makeFlagsArray=(SUBDIRS=$PWD/src);
  '';

#i donno if it could work with recent setup.
# i recommand firejail with --net option instead.
  meta = with stdenv.lib; {
    #broken = true; #not tested
    inherit (src.meta) homepage;
    description = "Perform network trace of a single process by using network namespaces";
    platforms = platforms.unix;
    license = licenses.gpl2;
    maintainers = with maintainers; [ genesis ];
  };
}
