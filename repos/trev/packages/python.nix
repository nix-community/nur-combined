{
  pythonPackages,
}:
rec {
  modal = pythonPackages.callPackage ./modal { inherit synchronicity; };
  nvtop-exporter = pythonPackages.callPackage ./nvtop-exporter { };
  opengrep = pythonPackages.callPackage ./opengrep { };
  synchronicity = pythonPackages.callPackage ./synchronicity { };
  uv-build-latest = pythonPackages.callPackage ./uv-build { };
  yt-dlp = pythonPackages.callPackage ./yt-dlp { inherit yt-dlp-ejs; };
  yt-dlp-ejs = pythonPackages.callPackage ./yt-dlp/ejs.nix { };
}
