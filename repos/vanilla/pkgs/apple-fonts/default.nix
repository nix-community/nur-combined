{ pkgs, ... }:
{
  SF-Pro = (pkgs.callPackage ./common.nix {
    name = "SF-Pro";
    fontName = "SF Pro Fonts";
    sha256 = "sha256-HtJ/KdIVOdYocuzQ8qkzTAm7bMITCq3Snv+Bo9WO9iA=";
  });
  SF-Compact = (pkgs.callPackage ./common.nix {
    name = "SF-Compact";
    fontName = "SF Compact Fonts";
    sha256 = "sha256-7gRJxuB+DOxS6bzHXFNjNH2X4kmO1MhJN2zK5he2XRU=";
  });
  SF-Mono = (pkgs.callPackage ./common.nix {
    name = "SF-Mono";
    fontName = "SF Mono Fonts";
    sha256 = "sha256-ulmhu5kXy+A7//frnD2mzBs6q5Jx8r6KwwaY7gmoYYM=";
  });
  SF-Arabic = (pkgs.callPackage ./common.nix {
    name = "SF-Arabic";
    fontName = "SF Arabic Fonts";
    sha256 = "sha256-8382K8rq/Myas47Pe0SZ6ZpmQljz2ut+X8Orkm1yemo=";
  });
  NY = (pkgs.callPackage ./common.nix {
    name = "NY";
    fontName = "NY Fonts";
    sha256 = "sha256-Rr0UpJa7kemczCqNn6b8HNtW6PiWO/Ez1LUh/WNk8S8=";
  });
}
