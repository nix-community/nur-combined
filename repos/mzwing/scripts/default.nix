{pkgs}:
(import ../internal/discover.nix {inherit (pkgs) lib;}).outputs {
  dir = ./.;
  args = {inherit pkgs;};
}
