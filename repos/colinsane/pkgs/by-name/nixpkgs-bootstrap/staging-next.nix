{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "a5f3e19606ec757565faeafc64131988b843f3c9";
  sha256 = "sha256-JLe0rhA4dVIS/689ISp6TJ3SIoAsMih1QnBibFk6M88=";
  version = "0-unstable-2025-01-13";
  branch = "staging-next";
}
