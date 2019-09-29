{ pkgs }:

{
  hoverfly = pkgs.callPackage ./development/tools/hoverfly {};
  ix = pkgs.callPackage ./misc/ix {};
  metals = pkgs.callPackage ./development/tools/metals {};
  qarma = pkgs.callPackage ./misc/qarma {
    inherit (pkgs) stdenv fetchFromGitHub pkgconfig;
    inherit (pkgs.qt5) qtbase qmake qttools qtmacextras qtx11extras;
  };
  scripts = pkgs.callPackage ./misc/scripts {
    inherit pkgs; inherit (pkgs) stdenv;
  };
  zenity = pkgs.callPackage ./misc/zenity {};
} // (if pkgs.stdenv.isDarwin then {
  yabai = pkgs.callPackage ./os-specific/darwin/yabai {
    inherit (pkgs) stdenv fetchFromGitHub;
    inherit (pkgs.darwin.apple_sdk.frameworks) Carbon Cocoa ScriptingBridge;
  };
  } else {
  rofi-emoji = pkgs.callPackage ./misc/rofi-emoji {};
  rofi-wifi-menu = pkgs.callPackage ./misc/rofi-wifi-menu {};
})
