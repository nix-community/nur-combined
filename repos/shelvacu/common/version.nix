{
  config,
  inputs,
  lib,
  pkgs,
  vacuModuleType,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (inputs) self;
  anyRev = attrs: toString (attrs.rev or attrs.dirtyRev or "unk");
  anyShortRev = attrs: toString (attrs.shortRev or attrs.dirtyShortRev or "unk");
  fmt = pkgs.formats.json {};
  infoFile = fmt.generate "vacu-version-info.json" config.vacu.versionInfo;
in
{
  imports = [ ]
  ++ lib.optional (vacuModuleType == "nixos" || vacuModuleType == "nix-on-droid") {
    environment.etc."vacu/info.json".source = infoFile;
  }
  ;
  options.vacu = {
    versionInfo = lib.mkOption {
      type = fmt.type;
      readOnly = true;
    };
    versionId = mkOption {
      type = types.str;
      readOnly = true;
    };
  };
  config.vacu = {
    versionId = "${anyShortRev self}-${self.lastModifiedDate or "unk"}";
    versionInfo = {
      rev = anyRev self;
      inherit (self) lastModified lastModifiedDate;
      inherit (config.vacu) versionId;
      inherit vacuModuleType;
      inputRevs = lib.mapAttrs (_: v: anyRev v) inputs;
    }
    // lib.optionalAttrs (!config.vacu.isMinimal) {
      flakePath = self.outPath;
      inherit inputs;
    };
  };
}
