{ newScope, callPackage, stdenv, fetchFromGitHub
, Carbon, Cocoa, ApplicationServices
, imagemagick }:

let

  _cfg = {
    repo = "chunkwm";
    sha256 = "0w8q92q97fdvbwc3qb5w44jn4vi3m65ssdvjp5hh6b7llr17vspl";
    version = "0.4.9";
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
