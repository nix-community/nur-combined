{ super, modules, ... }:
with super.lib;
collectBlock "overlay" modules
