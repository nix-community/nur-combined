{
  pkgs ? import <nixpkgs> { },
}:

{
  kose-font = pkgs.callPackage ./pkgs/kose-font { };
  maoken-assorted-sans = pkgs.callPackage ./pkgs/maoken-assorted-sans { };
  resource-han-rounded = pkgs.callPackage ./pkgs/resource-han-rounded { };
  sddm-lain-wired-theme = pkgs.callPackage ./pkgs/sddm-lain-wired-theme { };
  sddm-sugar-candy = pkgs.callPackage ./pkgs/sddm-sugar-candy { };
  klassy = pkgs.libsForQt5.callPackage ./pkgs/klassy { };
  klassy-qt6 = pkgs.kdePackages.callPackage ./pkgs/klassy-qt6 { };
  # Iosevka Builds
  iosevka-minoko = pkgs.callPackage ./pkgs/iosevka-minoko { };
  iosevka-aile-minoko = pkgs.callPackage ./pkgs/iosevka-aile-minoko { };
  iosevka-minoko-e = pkgs.callPackage ./pkgs/iosevka-minoko-e { };
  iosevka-minoko-term = pkgs.callPackage ./pkgs/iosevka-minoko-term { };
}
