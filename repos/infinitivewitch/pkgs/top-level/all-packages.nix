{ pkgs }:
rec {
  audio-scripts = pkgs.callPackage ../applications/audio/audio-scripts { };
}
