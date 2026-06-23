{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "15ac393dce7be77bad9b912b1f24550244184153";
  sha256 = "sha256-qnO59A3TjBPBQNyEVRb2F5aQTRonIjCKh6bLVsWXBoM=";
  version = "unstable-2026-06-22";
  branch = "staging";
}
