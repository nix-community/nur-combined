{ patched ? false, stdenv, mylibs, lib }:
stdenv.mkDerivation (mylibs.fetchedGithub ./af_feedmod.json // {
  patches = lib.optionals patched [ ./type_replace.patch ];
  installPhase = ''
    mkdir $out
    cp init.php $out
    '';
  passthru.pluginName = "af_feedmod";
})
