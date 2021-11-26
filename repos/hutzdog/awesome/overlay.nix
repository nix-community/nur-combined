final: prev: {
  awesome = (prev.awesome.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "awesomeWM";
      repo = "awesome";
      rev = "2eb035e1257c05aaaea33540e3db8dea504c2d13";
      sha256 = "10k1bkif7mqqhgwbvh0vi13gf1qgxszack3r0shmsdainm37hqz3";
    };
    GI_TYPELIB_PATH = "${prev.playerctl}/lib/girepository-1.0:"
      + "${prev.upower}/lib/girepository-1.0:"
      + old.GI_TYPELIB_PATH;
  })).override {
    stdenv = prev.clangStdenv;
    gtk3Support = true;
  };
}
