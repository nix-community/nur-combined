final: prev: {
  awesome = (prev.awesome.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "awesomeWM";
      repo = "awesome";
      rev = "832483dd60ba194f3ae0200ab39a3a548c26e910";
      sha256 = prev.lib.fakeSha256;
    };
    GI_TYPELIB_PATH = "${prev.playerctl}/lib/girepository-1.0:"
      + "${prev.upower}/lib/girepository-1.0:" + old.GI_TYPELIB_PATH;
  })).override {
    stdenv = prev.clangStdenv;
    luaPackages = prev.lua52Packages;
    gtk3Support = true;
  };
}
