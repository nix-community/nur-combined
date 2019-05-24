self: super: {
  elinks = super.elinks.overrideAttrs (old:
    self.mylibs.fetchedGithub ./elinks.json // rec {
      preConfigure = ''sh autogen.sh'';
      buildInputs = old.buildInputs ++ (with self; [ gettext automake autoconf ]);
      configureFlags = [
        "--disable-smb" "--without-x" "--enable-cgi"
        "--enable-leds" "--enable-256-colors"
        "--enable-html-highlight" "--with-zlib"
        ];
      patches = [];
    }
  );
}
