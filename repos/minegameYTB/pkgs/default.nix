{ lib, callPackage, pkgs }:

rec {
 ### Utilities
 sshrm = callPackage ./tools/sshrm {}; 
 GLFfetch = callPackage ./misc/GLFfetch {};
 GLFfetch-glfos = GLFfetch.override { glfIcon = "GLFos"; };
 gsettings-diff = callPackage ./tools/gsettings-diff {};

 ### Editor set
 editor = rec {
   msedit-bin = callPackage ./editor/msedit-bin {};
   msedit = callPackage ./editor/msedit {};
 };

 ### dev set
 dev = rec {
   ### Without option (with clang variant)
   fhsEnv-shell = callPackage ./tools/fhsEnv-shell {};
   fhsEnv-shell-clang = fhsEnv-shell.override { useClang = true; };

   ### With kernel-tools
   fhsEnv-shell-krnl = fhsEnv-shell.override{ kernel-tools = true; };
   
   ### With buildroot-tools
   fhsEnv-shell-buildroot = fhsEnv-shell.override { buildroot-tools = true; };
   
   ### With debian-tools
   fhsEnv-shell-deb-tools = fhsEnv-shell.override { debian-tools = true; };
   fhsEnv-shell-deb-tools-clang = fhsEnv-shell.override { debian-tools = true; useClang = true; };
   fhsEnv-shell-deb-tools-krnl = fhsEnv-shell.override { debian-tools = true; kernel-tools = true; };
   
   ### With redhat-tools
   fhsEnv-shell-rh-tools = fhsEnv-shell.override { redhat-tools = true; };
   fhsEnv-shell-rh-tools-clang = fhsEnv-shell.override { redhat-tools = true; useClang = true; };
   fhsEnv-shell-rh-tools-krnl = fhsEnv-shell.override { redhat-tools = true; kernel-tools = true; };
   
   ### All configuration (With or without clang)
   fhsEnv-shell-all = fhsEnv-shell.override { kernel-tools = true; buildroot-tools = true; };
   fhsEnv-shell-all-specific = fhsEnv-shell.override { redhat-tools = true; debian-tools = true; kernel-tools = true; buildroot-tools = true; };
   fhsEnv-shell-all-specific-nokrnl = fhsEnv-shell.override { redhat-tools = true; debian-tools = true; buildroot-tools = true; useClang = true;};
 };

 ### Theme sets
 theme = rec {
   marble-shell-filled = callPackage ./theme/marble-shell-filled {};
   
   ### marble-shell to marble-shell-filled with warning when this attribute is called
   #marble-shell = let
   #   buildPackage = callPackage ./theme/marble-shell-filled {};
   # in 
   #   builtins.warn
   #   "[2024/03/12] marble-shell has been renamed to marble-shell-filled, consider migrating to this new name before deleting this attribute in 1 month. (nur.repos.minegameYTB.theme.marble-shell -> nur.repos.minegameYTB.theme.marble-shell-filled)"
   #   buildPackage;
 };

 # some-qt5-package = libsForQt5.callPackage ./some-qt5-package { };
 # ...
}
