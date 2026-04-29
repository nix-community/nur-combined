{
  lib,
  godot3-export-templates,
}:

godot3-export-templates.overrideAttrs (
  attrs: attrsSuper: {
    pname = "${lib.removeSuffix "-export-templates" attrsSuper.pname}-runtime";

    # fix audio driver problems
    shouldAddLinkFlagsToPulse = true;
    shouldWrapBinary = true;
    shouldPatchBinary = true;

    installedGodotBinName = "godot3-template";
    godotBinInstallPath = "bin";
    meta = attrsSuper.meta // {
      mainProgram = attrs.installedGodotBinName;
    };
  }
)
