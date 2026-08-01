# Custom packages
# build using 'nix build .#example-package'

{
  pkgs,
}:

let
  callPackageDir = dir: pkgs.callPackage (dir + "/package.nix") { };
in
{
  bitbucket-cli = callPackageDir ./bitbucket-cli;
  clickup-cli = callPackageDir ./clickup-cli;
  dmenu-wpctl = callPackageDir ./dmenu-wpctl;
}
