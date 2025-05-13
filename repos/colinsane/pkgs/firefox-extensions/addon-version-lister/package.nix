{
  static-nix-shell
}:
static-nix-shell.mkYsh {
  pname = "addon-version-lister";
  pkgs = [ "common-updater-scripts" "coreutils" "curl" ];
  srcRoot = ./.;
}
