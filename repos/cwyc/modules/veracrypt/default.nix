{config, pkgs, lib, ...}:
let
  enable = config.veracrypt != {};
  nullFilePath = toString ( pkgs.writeTextFile {name="emptyfile"; text="";} );
  pkg = "${pkgs.veracrypt}/bin/veracrypt";
  
  combineSets = sets: builtins.foldl' lib.attrsets.recursiveUpdate {} sets;
  
  permount = path: {device, keyfiles, passwordFile, pim, extraCommandLineOptions, onBoot, extraUnitEntries, uidUser, gidGroup, umask, extraFSOptions}:
    let
      adjustedName = builtins.replaceStrings ["/"] ["-"] (builtins.substring 1 50 path);      
      passwordPath = if passwordFile == null then nullFilePath else passwordFile;
      keyfileConcat = builtins.concatStringsSep "," keyfiles;      
      
      uidOption = if uidUser == null then [] else [ "uid=$UIDVAR" ];
      uidScript = if uidUser == null then "" else "UIDVAR=$(id -u ${uidUser})";
      gidOption = if gidGroup == null then [] else [ "gid=$GIDVAR" ];
      gidScript = if gidGroup == null then "" else "GIDVAR=$(getent group ${gidGroup}| cut -d: -f3)";
      umaskOption = if umask == null then [] else [ "umask=${umask}" ];
      fsOptions = builtins.concatStringsSep "," (uidOption ++ gidOption ++ umaskOption ++ extraFSOptions);
      
      startScript = pkgs.writeScript "vcstart.sh" ''
        #!${pkgs.bash}/bin/bash
        ${uidScript}
        ${gidScript}
        echo $uid
        echo $gid
        ${pkgs.coreutils}/bin/cat ${passwordPath} | ${pkg} --text --non-interactive --stdin ${device} ${path} --pim=${toString pim} --keyfiles=${keyfileConcat} --protect-hidden=no --fs-options=${fsOptions} ${extraCommandLineOptions}
      '';
      
      stopScript = pkgs.writeScript "vcstop.sh" ''
        #!${pkgs.bash}/bin/bash
        ${pkg} -d ${device}
      '';
      
    in {
      "${adjustedName}-veracrypt.service" = {
        text = ''
          [Unit]
          Description=Veracrypt mount for ${path};
          ${extraUnitEntries}
          [Service]
          Type=oneshot
          RemainAfterExit=yes
          ExecStart=${startScript}
          ExecStop=${stopScript}
          Environment="PATH=/run/current-system/sw/bin/"
        '';
      } // (lib.attrsets.optionalAttrs onBoot {wantedBy = "multi-user.target";}) ;
    };
in
{
  options = with lib.types; let mkOption = lib.options.mkOption; in {
    veracrypt = mkOption {
      type = attrsOf ( submodule { options = {
        device = mkOption {
          type = str;
          description = "Path to device or container file to mount";
        };
        keyfiles = mkOption { 
          type = listOf str; 
          default = [];
          description = "List of paths to keyfiles";
        };
        passwordFile = mkOption {
          type = nullOr str; 
          default = null; 
          description = "Path to a file containing the password. Don't set for an empty password.";
        };
        pim = mkOption {
          type = ints.unsigned;
          default = 0;
        };
        
        extraCommandLineOptions = mkOption {
          type = separatedString " ";
          default = "";
          description = "Extra command line options for veracrypt";
          example = "--fs-options='umask=007,uid=1000,gid=1000'";
        };
        onBoot = mkOption {
          type = bool;
          default = true;
          description = "Whether to have systemd mount this volume on boot";
        };
        extraUnitEntries = mkOption {
          type = lines;
          default = "";
          description = "Extra entries in the [Unit] section of the systemd unit";
          example = "Wants=dev-sda6.device";
        };
        
        uidUser = mkOption {
          type = nullOr str;
          default = null;
          description = "The user to own the filesystem. Sets the uid mount option. Keep null to omit.";
          example = "admin";
        };
        gidGroup = mkOption {
          type = nullOr str;
          default = null;
          description = "The group to own the filesystem. Sets the gid mount option. Keep null to omit.";
          example = "users";
        };
        umask = mkOption {
          type = nullOr str;
          default = null;
          description = "The umask mount option. Keep null to omit.";
          example = "000";
        };
        extraFSOptions = mkOption {
          type = listOf str;
          default = [];
          description = "Extra filesystem mount options.";
        };
      };});
      default = {};
      description = ''
        Declarative veracrypt mounts as systemd services.
        Takes an attribute set where names correspond to the mount point.
        Does not support protecting hidden volume yet.
        Note that NTFS volumes don't carry linux file permissions and will be owned by root, unless uidUser, uidGroup, and umask options are used to adjust permissions.
      '';
    };
  };
  config = lib.mkIf (config.veracrypt != {}) {
    systemd.units = combineSets (lib.attrsets.mapAttrsToList permount config.veracrypt);
  };
}
