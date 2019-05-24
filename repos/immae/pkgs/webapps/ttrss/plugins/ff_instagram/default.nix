{ stdenv, mylibs }:
stdenv.mkDerivation (mylibs.fetchedGithub ./ff_instagram.json // {
  installPhase = ''
    mkdir $out
    cp -a . $out
    '';
  passthru.pluginName = "ff_instagram";
})
