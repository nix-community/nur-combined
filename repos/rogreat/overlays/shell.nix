{
  pkgs ? import <nixpkgs> { overlays = [ (import ./yt-dlp-nightly) ]; },
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    yt-dlp-nightly
  ];
}
