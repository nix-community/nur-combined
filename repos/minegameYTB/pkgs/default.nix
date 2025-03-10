{ lib, callPackage, pkgs }:

{
 ### Utilities
 sshrm = callPackage ./sshrm {};
 fhsEnv-dev = callPackage ./fhsEnv-dev {};
 GLFfetch = callPackage ./GLFfetch {};
 GLFfetch-glfos = callPackage ./GLFfetch { glfIcon = "GLFos"; };

 ### Theme sets
 theme = {
   marble-shell-filled = callPackage ./marble-shell-filled {};
   
   ### marble-shell to marble-shell-filled with warning when this attribute is called
   marble-shell = let
      buildPackage = callPackage ./marble-shell-filled {};
    in 
      builtins.warn
      "marble-shell has been renamed to marble-shell-filled, consider migrating to this new name before deleting this attribute in 1 month. (nur.repos.minegameYTB.theme.marble-shell -> nur.repos.minegameYTB.theme.marble-shell-filled)"
      buildPackage;
 };

 # some-qt5-package = libsForQt5.callPackage ./some-qt5-package { };
 # ...
}
