{
  common-updater-scripts,
  coreutils,
  curl,
  static-nix-shell,
}:
static-nix-shell.mkYsh {
  pname = "addon-version-lister";
  pkgs = {
    inherit 
      common-updater-scripts
      coreutils
      curl
      ;
  };
  srcRoot = ./.;
}
