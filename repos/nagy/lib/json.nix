{
  pkgs,
  lib ? pkgs.lib,
}:

{

  importJSON = {
    check = lib.hasSuffix ".json";
    __functor = _self: filename: lib.importJSON filename;
  };

  importTOML = {
    check = lib.hasSuffix ".toml";
    __functor = _self: filename: lib.importTOML filename;
  };

}
