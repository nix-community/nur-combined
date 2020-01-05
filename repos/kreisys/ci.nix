import ./release.nix {
  inherit (import nix/sources.nix) pkgs;
  supportedSystems = [ "x86_64-darwin" "x86_64-linux" ];
  scrubJobs = true;
}
