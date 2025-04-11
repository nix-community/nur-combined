{ lib, callPackage, pkgs }:

{
 ### Utilities
 sshrm = callPackage ./sshrm {}; 
 GLFfetch = callPackage ./GLFfetch {};
 GLFfetch-glfos = callPackage ./GLFfetch { glfIcon = "GLFos"; };

 ### dev set
 dev = {
   ### Without option (with clang variant)
   fhsEnv-shell = callPackage ./fhsEnv-shell {};
   fhsEnv-shell-clang = callPackage ./fhsEnv-shell { useClang = true; };

   ### With kernel-tools
   fhsEnv-shell-krnl = callPackage ./fhsEnv-shell { kernel-tools = true; };
   
   ### With buildroot-tools
   fhsEnv-shell-buildroot = callPackage ./fhsEnv-shell { buildroot-tools = true; };
   
   ### With debian-tools
   fhsEnv-shell-deb-tools = callPackage ./fhsEnv-shell { debian-tools = true; };
   fhsEnv-shell-deb-tools-clang = callPackage ./fhsEnv-shell { debian-tools = true; useClang = true; };
   fhsEnv-shell-deb-tools-krnl = callPackage ./fhsEnv-shell { debian-tools = true; kernel-tools = true; };
   
   ### With redhat-tools
   fhsEnv-shell-rh-tools = callPackage ./fhsEnv-shell { redhat-tools = true; };
   fhsEnv-shell-rh-tools-clang = callPackage ./fhsEnv-shell { redhat-tools = true; useClang = true; };
   fhsEnv-shell-rh-tools-krnl = callPackage ./fhsEnv-shell { redhat-tools = true; kernel-tools = true; };
   
   ### All configuration (With or without clang)
   fhsEnv-shell-all = callPackage ./fhsEnv-shell { kernel-tools = true; buildroot-tools = true; };
   fhsEnv-shell-all-specific = callPackage ./fhsEnv-shell { redhat-tools = true; debian-tools = true; kernel-tools = true; buildroot-tools = true; };
   fhsEnv-shell-all-specific-nokrnl = callPackage ./fhsEnv-shell { redhat-tools = true; debian-tools = true; buildroot-tools = true; useClang = true;};
 };

 ### Theme sets
 theme = {
   marble-shell-filled = callPackage ./marble-shell-filled {};
   
   ### marble-shell to marble-shell-filled with warning when this attribute is called
   marble-shell = let
      buildPackage = callPackage ./marble-shell-filled {};
    in 
      builtins.warn
      "[2024/03/12] marble-shell has been renamed to marble-shell-filled, consider migrating to this new name before deleting this attribute in 1 month. (nur.repos.minegameYTB.theme.marble-shell -> nur.repos.minegameYTB.theme.marble-shell-filled)"
      buildPackage;
 };

 # some-qt5-package = libsForQt5.callPackage ./some-qt5-package { };
 # ...
}
