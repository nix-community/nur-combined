{ lib }:
let
  schema = builtins.fromJSON (builtins.readFile ../pkgs/fluxdown-server/settings-schema.json);
  valueType =
    field:
    {
      Bool = lib.types.bool;
      Integer = lib.types.ints.between field.min field.max;
      Float = lib.types.addCheck lib.types.number (value: value >= field.min);
      Enum = lib.types.enum field.values;
      Text = lib.types.str;
    }
    .${field.kind};
in
lib.mapAttrs (
  name: field:
  lib.mkOption {
    type = lib.types.nullOr (valueType field);
    default = null;
    description = ''
      Upstream daemon setting `${name}` (${field.kind}).
      Upstream default: `${field.default}`. Null leaves the stored value unchanged.
      Declared values are reapplied on service startup. Do not put secrets here;
      use settingsFile instead. Upstream performs additional semantic validation.
    '';
  }
) (lib.filterAttrs (_: field: field.kind != "ReadOnly") schema.fields)
