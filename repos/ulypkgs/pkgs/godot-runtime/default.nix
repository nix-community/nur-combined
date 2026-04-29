{
  lib,
  godot,
}:

godot.export-template.overrideAttrs (attrsSuper: {
  pname = "${lib.removeSuffix "-template" attrsSuper.pname}-runtime";
  sconsFlags = attrsSuper.sconsFlags ++ [ "disable_path_overrides=no" ];
})
