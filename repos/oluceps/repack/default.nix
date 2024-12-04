{
  lib,
  config,
  pkgs,
  ...
}@args:
let
  repackNames = map (lib.removeSuffix ".nix") (
      lib.attrNames (lib.filterAttrs (n: v: n != "default.nix") (builtins.readDir ./.))
    );
  genReIf = name: lib.mkIf config.repack.${name}.enable;
in
{
  options.repack = lib.genAttrs repackNames (n: {
    enable = lib.mkEnableOption "enable repacked ${n} module";
  });
  imports = map (
    n:
    import ./${n}.nix (
      args
      // {
        inherit pkgs;
        reIf = genReIf n;
      }
    )
  ) repackNames;
}
