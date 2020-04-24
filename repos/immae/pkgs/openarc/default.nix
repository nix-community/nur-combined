{ stdenv, autoconf, automake, file, libtool, libbsd, mylibs, openssl, pkg-config, libmilter }:

stdenv.mkDerivation (mylibs.fetchedGithub ./openarc.json // rec {
  buildInputs = [ automake autoconf libbsd libtool openssl pkg-config libmilter ];

  configureFlags = [
    "--with-milter=${libmilter}"
  ];
  preConfigure = ''
    autoreconf --force --install
    sed -i -e "s@/usr/bin/file@${file}/bin/file@" ./configure
    '';
  meta = with stdenv.lib; {
    description = "Open source ARC implementation";
    homepage = https://github.com/trusteddomainproject/OpenARC;
    platforms = platforms.unix;
  };
})
