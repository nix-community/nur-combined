let
  modules = {
    cxadc = ./cxadc;
    vhs-decode = ./vhs-decode;
  };
  default = { ... }: {
    imports = builtins.attrValues modules;
  };
in
modules // { inherit default; }
