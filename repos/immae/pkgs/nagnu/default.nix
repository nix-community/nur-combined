{ stdenv, mylibs, ncurses, curl }:
stdenv.mkDerivation (mylibs.fetchedGithub ./nagnu.json // rec {
  buildInputs = [ ncurses curl ];
  installPhase = ''
    mkdir -p $out/bin
    cp nagnu $out/bin
    mkdir -p $out/share/doc/nagnu
    cp nagnu.conf.sample $out/share/doc/nagnu
    mkdir -p $out/share/man/man8
    cp docs/nagnu.8 $out/share/man/man8
    '';
})
