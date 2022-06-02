final: prev: {
  awesome = (prev.awesome.overrideAttrs (old: {
    patches = [];
    src = prev.fetchFromGitHub {
      owner = "awesomeWM";
      repo = "awesome";
      rev = "3a542219f3bf129546ae79eb20e384ea28fa9798";
      sha256 = "4z3w6iuv+Gw2xRvhv2AX4suO6dl82woJn0p1nkEx3uM=";
    };
    GI_TYPELIB_PATH = "${prev.playerctl}/lib/girepository-1.0:"
      + "${prev.upower}/lib/girepository-1.0:"
      + old.GI_TYPELIB_PATH;
  })).override {
    gtk3Support = true;
  };
}
