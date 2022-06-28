final: prev: {
  awesome-master = let
    rev = "3a542219f3bf129546ae79eb20e384ea28fa979";
  in (prev.awesome.overrideAttrs (old: {
    version = "master-${rev}";
    patches = [];
    src = prev.fetchFromGitHub {
      owner = "awesomeWM";
      repo = "awesome";
      inherit rev;
      sha256 = "4z3w6iuv+Gw2xRvhv2AX4suO6dl82woJn0p1nkEx3uM=";
    };
    GI_TYPELIB_PATH = "${prev.playerctl}/lib/girepository-1.0:"
      + "${prev.upower}/lib/girepository-1.0:"
      + old.GI_TYPELIB_PATH;
  })).override {
    gtk3Support = true;
  };
  awesome = throw "renamed to 'awesome-master', since stable would be used here on update this error exists. For the nixpkgs version, use 'awesome-stable'";
  awesome-stable = prev.awesome;
}
