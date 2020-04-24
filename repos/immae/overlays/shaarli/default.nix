self: super: {
  shaarli = varDir: super.shaarli.overrideAttrs (old: rec {
    version = "0.10.2";
    src = self.fetchurl {
      url = "https://github.com/shaarli/Shaarli/releases/download/v${version}/shaarli-v${version}-full.tar.gz";
      sha256 = "0h8sspj7siy3vgpi2i3gdrjcr5935fr4dfwq2zwd70sjx2sh9s78";
    };
    patchPhase = "";
    patches = (old.patches or []) ++ [ ./shaarli_ldap.patch ];
    installPhase = (old.installPhase or "") + ''
      cp .htaccess $out/
      ln -sf ${varDir}/{cache,pagecache,tmp,data} $out/
      '';
  });
}
