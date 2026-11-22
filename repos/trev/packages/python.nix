{
  pythonPackages,
}:
rec {
  aioquic-latest = pythonPackages.callPackage ./aioquic { inherit pylsqpack-latest; };
  kagiapi = pythonPackages.callPackage ./kagimcp/kagiapi.nix { };
  kagimcp = pythonPackages.callPackage ./kagimcp { };
  modal = pythonPackages.callPackage ./modal { inherit synchronicity; };
  nvtop-exporter = pythonPackages.callPackage ./nvtop-exporter { inherit uv-build-latest; };
  opengrep = pythonPackages.callPackage ./opengrep { };
  pylsqpack-latest = pythonPackages.callPackage ./aioquic/pylsqpack.nix { };
  synchronicity = pythonPackages.callPackage ./synchronicity { };
  uv-build-latest = pythonPackages.callPackage ./uv-build { };
  yt-dlp = pythonPackages.callPackage ./yt-dlp { inherit yt-dlp-ejs; };
  yt-dlp-ejs = pythonPackages.callPackage ./yt-dlp/ejs.nix { };
}
