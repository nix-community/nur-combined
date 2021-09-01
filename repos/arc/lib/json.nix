{ lib }: with lib; {
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
}
