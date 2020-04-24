{ stdenv, mylibs, autoconf, automake,
  libtool, pkg-config, naemon,
  varDir ? "/var/lib/naemon",
  etcDir ? "/etc/naemon"
}:
stdenv.mkDerivation (mylibs.fetchedGithub ./naemon-livestatus.json // {
  preConfigure = ''
    ./autogen.sh || true
    '';

  configureFlags = [
    "--localstatedir=${varDir}"
    "--sysconfdir=${etcDir}"
  ];

  preInstall = ''
    substituteInPlace Makefile --replace \
      '@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am' \
      '@$(MAKE) $(AM_MAKEFLAGS) install-exec-am'
  '';

  buildInputs = [ autoconf automake libtool pkg-config naemon ];
})
