{ stdenv, mylibs }:
stdenv.mkDerivation (mylibs.fetchedGithub ./predixy.json // {
  installPhase = ''
    mkdir -p $out/bin
    cp src/predixy $out/bin
    mkdir -p $out/share
    cp -r doc $out/share
    cp -r conf $out/share/doc
    '';
})
