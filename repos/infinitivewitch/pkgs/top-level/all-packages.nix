{ pkgs }:
rec {
  chromebook-audio = pkgs.callPackage ../applications/audio/chromebook-audio { };
}
