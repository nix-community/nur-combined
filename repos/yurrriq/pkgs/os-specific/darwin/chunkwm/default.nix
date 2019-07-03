{ newScope, callPackage, stdenv, fetchFromGitHub
, Carbon, Cocoa, ApplicationServices
, imagemagick }:

let

  _cfg = {
    repo = "chunkwm";
    sha256 = "0vk0lqfbiwf8yq61kn1qpcy69zam9jkbypi1ssbbx62m4acbf8m5";
    version = "0.4.10";
  };

  self = chunkwm;

  callPackage = newScope self;

  chunkwm = with self; {

    core = callPackage ./core.nix {
      cfg = _cfg // { name = "core"; };
      inherit Carbon Cocoa;
    };

    border = callPackage ./plugin.nix {
      cfg = _cfg // { name = "border"; };
      inherit Carbon Cocoa ApplicationServices;
    };

    ffm = callPackage ./plugin.nix {
      cfg = _cfg // { name = "ffm"; };
      inherit Carbon Cocoa ApplicationServices;
    };

    tiling = callPackage ./plugin.nix {
      cfg = _cfg // { name = "tiling"; };
      inherit Carbon Cocoa ApplicationServices;
    };

    purify = callPackage ./plugin.nix {
      cfg = _cfg // { name = "purify"; };
      inherit Carbon Cocoa ApplicationServices;
    };

  }; in chunkwm
