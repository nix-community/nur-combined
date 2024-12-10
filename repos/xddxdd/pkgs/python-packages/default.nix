{
  pkgs,
  ifNotCI,
  _packages,
  createCallPackage,
  createLoadPackages,
  ...
}:
let
  callPackage = createCallPackage (_packages // pkgs.python3Packages // self);
  loadPackages = createLoadPackages callPackage;
  packages = loadPackages ./. {
    deepspeech-gpu = ifNotCI;
  };

  self = packages // {
    deepspeech-wrappers = ifNotCI (callPackage ./deepspeech-gpu/wrappers.nix { });
    piper-tts = callPackage ./piper-tts { piper-tts-native = pkgs.piper-tts; };
  };
in
self
