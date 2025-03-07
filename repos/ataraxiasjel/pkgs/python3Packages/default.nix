{
  callPackage,
  lib,
  pkgs,
}:

(lib.mapAttrs' (filename: _filetype: {
  name = lib.removeSuffix ".nix" filename;
  value = (callPackage (./. + "/${filename}") { });
}) (builtins.readDir ./.))
// {
  pyzstd = callPackage ./pyzstd {
    zstd-c = pkgs.zstd;
  };
}
