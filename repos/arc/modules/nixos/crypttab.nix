{ config, lib, ... }: with lib; let
  module = { ... }: {
    options.crypttab = {
      enable = mkEnableOption "crypttab";
      options = mkOption {
        type = with types; listOf str;
        default = [ "luks" ];
      };
    };
  };
in {
  options.fileSystems = mkOption {
    type = with types; attrsOf (submodule module);
  };
  config = {
    environment.etc.crypttab = let
      mapfs = fs: let
        keyFile = if fs.encrypted.keyFile != null then fs.encrypted.keyFile else "none";
        line = ''${fs.encrypted.label} ${fs.encrypted.blkDev} ${keyFile} ${concatStringsSep "," fs.crypttab.options}'';
      in warnIf fs.encrypted.enable "both initrd encryption and crypttab are enabled for ${fs.mountPoint}" line;
      crypttabFilesystems = filter (fs: fs.crypttab.enable) (attrValues config.fileSystems);
      text = concatMapStringsSep "\n" mapfs crypttabFilesystems;
    in mkIf (crypttabFilesystems != [ ]) {
      inherit text;
    };
  };
}
