self: super: {
  goaccess = super.goaccess.overrideAttrs(old: rec {
    name = "goaccess-${version}";
    version = "1.3";
    src = self.fetchurl {
      url = "https://tar.goaccess.io/${name}.tar.gz";
      sha256 = "16vv3pj7pbraq173wlxa89jjsd279004j4kgzlrsk1dz4if5qxwc";
    };
    configureFlags = old.configureFlags ++ [ "--enable-tcb=btree" ];
    buildInputs = old.buildInputs ++ [ self.tokyocabinet self.bzip2 ];
  });

}
