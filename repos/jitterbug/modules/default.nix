let
  modules = {
    cxadc = ./cxadc;
    decode = ./decode;
  };

  default =
    { ... }:
    {
      imports = builtins.attrValues modules;
    };
in
modules // { inherit default; }
