{ callPackages, pkgs }:

{
 sshrm = pkgs.callPackage ./sshrm {};
 fhsEnv-dev = pkgs.callPackage ./fhsEnv-dev {};
 GLFfetch = pkgs.callPackage ./GLFfetch {};
 GLFfetch-glfos = pkgs.callPackage ./GLFfetch { glfIcon = "GLFos"; };

 # some-qt5-package = pkgs.libsForQt5.callPackage ./some-qt5-package { };
 # ...
}
