{ pkgs, ... }:
{
  SF-Pro = (pkgs.callPackage ./common.nix {
    name = "SF-Pro";
    fontName = "SF Pro Fonts";
    sha256 = "sha256-o1Zis9kymOicTyDdTPGON2A5LNpDbgOD1XtyQOdxc0M=";
  });
  SF-Compact = (pkgs.callPackage ./common.nix {
    name = "SF-Compact";
    fontName = "SF Compact Fonts";
    sha256 = "sha256-SIht9sqmeijEeU4uLwm+tlZtFlTnD/G5GH8haUL6dlU=";
  });
  SF-Mono = (pkgs.callPackage ./common.nix {
    name = "SF-Mono";
    fontName = "SF Mono Fonts";
    sha256 = "sha256-jnhTTmSy5J8MJotbsI8g5hxotgjvyDbccymjABwajYw=";
  });
  SF-Arabic = (pkgs.callPackage ./common.nix {
    name = "SF-Arabic";
    fontName = "SF Arabic Fonts";
    sha256 = "sha256-99vnv+z3liEhaHw4rqdGcAOe74fPuWmMiBmLLd3/DP0=";
  });
  NY = (pkgs.callPackage ./common.nix {
    name = "NY";
    fontName = "NY Fonts";
    sha256 = "sha256-Rr0UpJa7kemczCqNn6b8HNtW6PiWO/Ez1LUh/WNk8S8=";
  });
}
