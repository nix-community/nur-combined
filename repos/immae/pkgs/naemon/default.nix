{ stdenv, mylibs, help2man, monitoring-plugins, autoconf, automake,
  libtool, glib, pkg-config, gperf,
  varDir ? "/var/lib/naemon",
  etcDir ? "/etc/naemon",
  cacheDir ? "/var/cache/naemon",
  logDir ? "/var/log/naemon",
  runDir ? "/run/naemon",
  user   ? "naemon",
  group  ? "naemon"
}:
stdenv.mkDerivation (mylibs.fetchedGithub ./naemon.json // {
  preConfigure = ''
    ./autogen.sh || true
    '';

  configureFlags = [
    "--localstatedir=${varDir}"
    "--sysconfdir=${etcDir}"
    "--with-pkgconfdir=${etcDir}"
    "--with-pluginsdir=${monitoring-plugins}/libexec"
    "--with-tempdir=${cacheDir}"
    "--with-checkresultdir=${cacheDir}/checkresults"
    "--with-logdir=${logDir}"
    "--with-naemon-user=${user}"
    "--with-naemon-group=${group}"
    "--with-lockfile=${runDir}/naemon.pid"
  ];

  preInstall = ''
    substituteInPlace Makefile --replace '$(MAKE) $(AM_MAKEFLAGS) install-exec-hook' ""
  '';

  buildInputs = [ autoconf automake help2man libtool glib pkg-config gperf ];
})
