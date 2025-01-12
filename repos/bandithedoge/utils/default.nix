{
  pkgs,
  callPackage',
  ...
}: {
  juce = callPackage' ./juce.nix;
}
