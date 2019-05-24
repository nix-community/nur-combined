{ varDir ? "/var/lib/rompr", stdenv, mylibs }:
stdenv.mkDerivation (mylibs.fetchedGithub ./rompr.json // {
  installPhase = ''
        cp -a . $out
        ln -sf ${varDir}/prefs $out/prefs
        ln -sf ${varDir}/albumart $out/albumart
  '';
})
