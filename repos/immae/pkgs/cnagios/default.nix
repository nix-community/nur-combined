{ stdenv, mylibs, perl, ncurses }:
stdenv.mkDerivation (mylibs.fetchedGithub ./cnagios.json // {
  configureFlags = [
    "--with-etc-dir=/etc/cnagios"
    "--with-var-dir=/var/lib/naemon"
    "--with-status-file=/var/lib/naemon/status.dat"
    "--with-nagios-data=4"
  ];

  prePatch = ''
    sed -i -e "s/-lcurses/-lncurses/" Makefile.in
  '';
  installPhase = ''
    install -dm755 $out/share/doc/cnagios
    install -Dm644 cnagiosrc $out/share/doc/cnagios/
    install -Dm644 cnagios.help $out/share/doc/cnagios/
    install -Dm644 cnagios.pl $out/share/doc/cnagios/
    install -dm755 $out/bin
    install -Dm755 cnagios $out/bin/
  '';
  buildInputs = [ perl ncurses ];
})
