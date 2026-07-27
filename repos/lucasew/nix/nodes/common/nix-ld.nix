{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.programs.nix-ld.enable {
  programs.nix-ld.libraries =
    with pkgs;
    [
      fuse
      libbsd
      curl
      lz4
    ]
    ++ (appimageTools.defaultFhsEnvArgs.targetPkgs pkgs)
    ++ (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs);

}
