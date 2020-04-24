{ stdenv, mylibs }:
stdenv.mkDerivation (mylibs.fetchedGithub ./fiche.json // rec {
  installPhase = ''
    mkdir -p $out/bin
    install -m 0755 fiche $out/bin/
  '';
})
