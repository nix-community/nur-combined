{pkgs}:
import ../internal/discover-outputs.nix {
  inherit (pkgs) lib;
  root = ./.;
  args = {inherit pkgs;};
}
