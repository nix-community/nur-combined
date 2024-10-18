{ lib, newScope }:

lib.makeScope newScope (self: {
  fetchLapcePlugin = self.callPackage ./fetchLapcePlugin.nix { };
  mkLapcePlugin = self.callPackage ./mkLapcePlugin.nix { };

  catppuccin = self.mkLapcePlugin {
    author = "Catppuccin-Holdings";
    name = "catppuccin";
    version = "0.1.18";
    hash = "sha256-CMZez58yYmgC07MX4jw7s3fccCMK2WP51oII/7GmOBw=";
    meta = {
      description = "Soothing pastel theme for Lapce";
      homepage = "https://github.com/catppuccin/lapce";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.federicoschonborn ];
    };
  };

  lapce-crates = self.mkLapcePlugin {
    author = "MathiasPius";
    name = "lapce-crates";
    version = "0.1.0";
    hash = "sha256-tyUn0a1FoRlMRYFPfSy7FzP2FFZ52s197kAma2rpgXA=";
    meta = {
      description = "Crates.io integration for Cargo.toml";
      homepage = "https://github.com/MathiasPius/lapce-crates";
      license = lib.licenses.asl20;
      maintainers = [ lib.maintainers.federicoschonborn ];
    };
  };

  lapce-go = self.mkLapcePlugin {
    author = "panekj";
    name = "lapce-go";
    version = "2023.1.0";
    hash = "sha256-HZJW28ve7xLoNOBxKNfFnPWs/Prk+/znvUh8jI6YwMI=";
    meta = {
      description = "Go for Lapce using gopls";
      homepage = "https://github.com/lapce-community/lapce-go";
      license = lib.licenses.asl20;
      maintainers = [ lib.maintainers.federicoschonborn ];
    };
  };

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

  lapce-toml = self.mkLapcePlugin {
    author = "panekj";
    name = "lapce-toml";
    version = "0.0.0";
    hash = "sha256-hSXo5d7DuresKfN8lDlC8SCJ/+NeWZcAH8Xbp3kUwNc=";
    meta = {
      description = "TOML for Lapce";
      homepage = "https://github.com/panekj/lapce-toml";
      license = lib.licenses.asl20;
      maintainers = [ lib.maintainers.federicoschonborn ];
    };
  };
})
