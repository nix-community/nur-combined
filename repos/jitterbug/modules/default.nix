let
  modules = {
    cxadc = ./cxadc;
    ld-decode = ./ld-decode;
    vhs-decode = ./vhs-decode;
  };

  default =
    { ... }:
    {
      imports = builtins.attrValues modules;
    };
in
modules // { inherit default; }
