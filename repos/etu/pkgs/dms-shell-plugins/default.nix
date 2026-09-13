{
  lib,
  callPackage,
  ...
}:
lib.recurseIntoAttrs {
  emojiLauncher = callPackage ./emoji-launcher.nix {};
  nixPackageRunner = callPackage ./nix-package-runner.nix {};
  quickCapture = callPackage ./quick-capture.nix {};
}
