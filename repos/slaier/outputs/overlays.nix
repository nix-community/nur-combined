{ super, modules, ... }:
with super.lib;
(collectBlock "overlay" modules) // {
  lib = final: prev: {
    lib = prev.lib // super.lib;
  };
}
