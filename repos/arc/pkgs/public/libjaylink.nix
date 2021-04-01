{ stdenv, fetchgit, autoreconfHook, pkgconfig, libusb1 }: stdenv.mkDerivation {
  pname = "libjaylink";
  version = "2019-10-03";
  nativeBuildInputs = [ pkgconfig autoreconfHook ];
  buildInputs = [ libusb1 ];

  src = fetchgit {
    #url = "git://git.zapb.de/libjaylink.git"; # appears to be down?
    url = "git://repo.or.cz/libjaylink.git";
    rev = "cfccbc9d6763733f1d14dff3c2dc5b75aaef136b";
    sha256 = "0z3hv2wadbmx8mf7kjfrcgp5ivi5lix0vapg24gykhadgg2a6gcm";
  };
}
