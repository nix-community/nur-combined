{ callPackage, pkgs }:

{
 sshrm = callPackage ./sshrm {};
 fhsEnv-dev = callPackage ./fhsEnv-dev {};
 GLFfetch = callPackage ./GLFfetch {};
 GLFfetch-glfos = callPackage ./GLFfetch { glfIcon = "GLFos"; };

 # some-qt5-package = libsForQt5.callPackage ./some-qt5-package { };
 # ...
}
