{ callPackage, pkgs }:

{
 ### Utilities
 sshrm = callPackage ./sshrm {};
 fhsEnv-dev = callPackage ./fhsEnv-dev {};
 GLFfetch = callPackage ./GLFfetch {};
 GLFfetch-glfos = callPackage ./GLFfetch { glfIcon = "GLFos"; };

 ### Theme sets
 theme = {
   marble-shell = callPackage ./marble-shell {};
   marble-shell-filled = callPackage ./marble-shell { variant = "filled"; };
 };

 # some-qt5-package = libsForQt5.callPackage ./some-qt5-package { };
 # ...
}
