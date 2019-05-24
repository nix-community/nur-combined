{ stdenv, mylibs }:
stdenv.mkDerivation (mylibs.fetchedGithub ./auth-ldap.json // {
  installPhase = ''
    mkdir $out
    cp plugins/auth_ldap/init.php $out
    '';
  passthru.pluginName = "auth_ldap";
})
