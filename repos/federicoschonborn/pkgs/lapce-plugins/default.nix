{ lib, newScope }:

lib.makeScope newScope (self: {
  fetchLapcePlugin = self.callPackage ./fetchLapcePlugin.nix { };
  mkLapcePlugin = self.callPackage ./mkLapcePlugin.nix { };

  lapce-rust = self.mkLapcePlugin {
    author = "dzhou121";
    name = "lapce-rust";
    version = "0.3.1932";
    hash = "sha256-LJ5tb37aIlTvbW5qCQBs9rOEV9M48BmzGsZD2J6WPw0=";
    meta = {
      description = "Rust for Lapce: powered by Rust Analyzer";
      homepage = "https://github.com/lapce/lapce-rust";
      license = lib.licenses.asl20;
      maintainers = [ lib.maintainers.federicoschonborn ];
    };
  };
})
