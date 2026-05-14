{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.systemd.tmpfiles.generateRules;
in
{
  options.systemd.tmpfiles.generateRules = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.int);
    default = { };
    description = ''
      Attribute set of directory paths to lists of UIDs that should be granted
      rwx ACL access. Generates both access/default ACL rules via systemd-tmpfiles
      (for the directory itself and new files) and a one-shot service that
      recursively applies ACLs to all existing files and subdirectories.
    '';
  };

  config = lib.mkIf (cfg != { }) {
    # Access ACLs on the directories themselves + default ACLs for inheritance
    systemd.tmpfiles.rules = lib.concatLists (
      lib.mapAttrsToList (
        directory: uids:
        lib.concatMap (uid: [
          "a ${directory} - - - - u:${toString uid}:rwx,g::---,m::rwx"
          "A ${directory} - - - - u:${toString uid}:rwx,g::---,m::rwx"
        ]) uids
      ) cfg
    );

    # One-shot service to recursively apply ACLs to existing files/directories.
    # This avoids the fragility of listing every subdirectory in generateRules.
    # After applying, any '.ssh', '.config/sops', or '.config/sops-nix' directories
    # under the target have the added ACLs stripped so private keys are never exposed.
    systemd.services.apply-generated-acls = {
      description = "Recursively apply ACLs from generateRules to existing files";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = lib.concatStringsSep "\n" (
        lib.concatLists (
          lib.mapAttrsToList (
            directory: uids:
            map (uid: ''
              if [ -d "${directory}" ]; then
                ${pkgs.acl}/bin/setfacl -R -m u:${toString uid}:rwx "${directory}" || true
                ${pkgs.acl}/bin/setfacl -R -d -m u:${toString uid}:rwx "${directory}" || true
                find "${directory}" -type d -name ".ssh" -exec ${pkgs.acl}/bin/setfacl -R -x u:${toString uid} {} + || true
                find "${directory}" -type d -name ".ssh" -exec ${pkgs.acl}/bin/setfacl -R -d -x u:${toString uid} {} + || true
                find "${directory}" -type d -path "*/.config/sops" -exec ${pkgs.acl}/bin/setfacl -R -x u:${toString uid} {} + || true
                find "${directory}" -type d -path "*/.config/sops" -exec ${pkgs.acl}/bin/setfacl -R -d -x u:${toString uid} {} + || true
                find "${directory}" -type d -path "*/.config/sops-nix" -exec ${pkgs.acl}/bin/setfacl -R -x u:${toString uid} {} + || true
                find "${directory}" -type d -path "*/.config/sops-nix" -exec ${pkgs.acl}/bin/setfacl -R -d -x u:${toString uid} {} + || true
              fi
            '') uids
          ) cfg
        )
      );
    };
  };
}
