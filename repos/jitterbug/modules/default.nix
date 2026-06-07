let
  modules = {
    cxadc = ./cxadc;
  };

  default =
    { ... }:
    {
      imports = builtins.attrValues modules;
    };
in
modules // { inherit default; }
