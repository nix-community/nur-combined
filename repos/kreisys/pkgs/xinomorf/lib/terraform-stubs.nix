{ lib, stringify, stringifyAttrs, attrsSnakeToCamel ? lib.id, snakeToCamel ? lib.id }:

{ vars }:

rec {
  data = type: name: attrs: {
    inherit type name attrs;
    __toString = self: ''
    data ${stringify self.type} ${stringify self.name} ${stringify self.attrs}
  '';
  };

  resource = type: name: attrs: list: {
    inherit type name attrs list;
    __toString = self: ''
      resource ${stringify self.type} ${stringify self.name} ${stringifyAttrs self.attrs self.list}
    '';
  };

  provider = name: attrs: {
    inherit name attrs;
    __toString = self: ''
      provider ${stringify self.name} ${stringify self.attrs}
    '';
  };

  provisioner = name: attrs: ''
    provisioner ${stringify name} ${stringify attrs}
  '';

  module = name: attrs: with lib; let
    getTfvars = path: if (builtins.readDir path) ? "terraform.tfvars.json" then importJSON "${path}/terraform.tfvars.json" else {};
    extraAttrs = if attrs ? source then getTfvars attrs.source else {};
  in {
    inherit name attrs;
    __toString = self: ''
      module ${stringify self.name} ${stringify (recursiveUpdate extraAttrs self.attrs)}
    '';
  };

  locals = attrs: ''
    locals ${stringify attrs}
  '';

  variable = name: attrs: ''
    variable ${stringify name} ${stringify attrs}
  '';

  var = vars;
}
