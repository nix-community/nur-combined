self: super: {
  isync = super.isyncUnstable.overrideAttrs (o: rec {
    name = "isync-git-${version}";
    version = "2018-07-01";
    src = super.fetchgit {
      url = "https://git.code.sf.net/p/isync/isync";
      rev = "37feeddbfb8d86fcd25f90c7928d5ea139b0feb4";
      sha256 = "0hsk1x8wsbpccj9xnd8dy5qx3scr1gwmdmpp0g08gmlbwkzkx73h";
    };
  });
}
