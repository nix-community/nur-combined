{ stdenv, mylibs }:
stdenv.mkDerivation (mylibs.fetchedGithub ./tumblr_gdpr_ua.json // {
  installPhase = ''
    mkdir $out
    cp -a . $out
    '';
  passthru.pluginName = "tumblr_gdpr_ua";
})
