{
  pkgs,
  _packages,
  createCallPackage,
  createLoadPackages,
  ...
}:
let
  callPackage = createCallPackage (_packages // pkgs.python3Packages // self);
  loadPackages = createLoadPackages callPackage;
  packages = loadPackages ./. { };

  self = packages // {
    piper-tts = callPackage ./piper-tts { piper-tts-native = pkgs.piper-tts; };
  };
in
self
