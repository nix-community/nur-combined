{ lib }: let
  inherit (lib) types;
  json = lib.arclib.json or (if lib ? json.types.primitive then lib.json else self);
  self = {
    primitives = with types; [ bool int float str ];
    types = {
      data = with types; oneOf [ json.types.primitive json.types.attrs json.types.list ] // {
        description = "json data";
      };
      primitive = types.nullOr (types.oneOf json.primitives);
      attrs = types.attrsOf json.types.data;
      list = types.listOf json.types.data;
    };
    type = json.types.data;
  };
in self
