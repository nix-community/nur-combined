{ stdenv, mylibs }:
stdenv.mkDerivation (mylibs.fetchedGithub ./ldap.json // rec {
  installPhase = ''
    mkdir -p $out
    cp plugin.php $out
    '';
  passthru.pluginName = "ldap";
})
