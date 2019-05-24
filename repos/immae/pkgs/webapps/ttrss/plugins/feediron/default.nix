{ patched ? false, stdenv, mylibs, lib }:
stdenv.mkDerivation (mylibs.fetchedGithub ./feediron.json // {
  patches = lib.optionals patched [ ./json_reformat.patch ];
  installPhase = ''
    mkdir $out
    cp -a . $out
    '';
  passthru.pluginName = "feediron";
})
