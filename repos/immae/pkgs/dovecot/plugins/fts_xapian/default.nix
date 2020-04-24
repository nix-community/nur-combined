{ stdenv, autoconf, automake, pkg-config, dovecot, libtool, xapian, icu, mylibs }:

stdenv.mkDerivation (mylibs.fetchedGithub ./fts-xapian.json // rec {
  buildInputs = [ dovecot autoconf automake libtool pkg-config xapian icu ];
  preConfigure = ''
    export PANDOC=false
    autoreconf -vi
    '';
  configureFlags = [
    "--with-dovecot=${dovecot}/lib/dovecot"
    "--without-dovecot-install-dirs"
    "--with-moduledir=$(out)/lib/dovecot"
  ];
})
