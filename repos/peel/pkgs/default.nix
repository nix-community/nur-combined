{ pkgs }:

{
  metals = pkgs.callPackage ./development/tools/metals {};
  scripts = pkgs.callPackage ./misc/scripts {
    inherit pkgs; inherit (pkgs) stdenv;
  };
} // (if pkgs.stdenv.isDarwin then {
  } else {
  rofi-emoji = pkgs.callPackage ./misc/rofi-emoji {};
  rofi-wifi-menu = pkgs.callPackage ./misc/rofi-wifi-menu {};
})
