self: super: {
  slrn = super.slrn.overrideAttrs (old: rec {
    version = "1.0.3a";
    name = "slrn-${version}";
    src = self.fetchurl {
      url = "http://www.jedsoft.org/releases/slrn/slrn-${version}.tar.bz2";
      sha256 = "1b1d9iikr60w0vq86y9a0l4gjl0jxhdznlrdp3r405i097as9a1v";
    };
    configureFlags = old.configureFlags ++ [ "--with-slrnpull" ];
  });
}
