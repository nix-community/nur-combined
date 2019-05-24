self: super: {
  shaarli = varDir: super.shaarli.overrideAttrs (old: {
    patchPhase = "";
    patches = (old.patches or []) ++ [ ./shaarli_ldap.patch ];
    installPhase = (old.installPhase or "") + ''
      cp .htaccess $out/
      ln -sf ${varDir}/{cache,pagecache,tmp,data} $out/
      '';
  });
}
