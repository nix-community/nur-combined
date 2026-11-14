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

  options.systemd.tmpfiles.generateRulesContinuous = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.int);
    default = { };
    description = ''
      Subset of directories (small, interactive ones like a git checkout)
      whose file ACLs are re-normalized every few minutes by a timer, using
      exactly the one-shot's file semantics (`m::rw-` + named-user `rw-`).
      New files are born with entries masked by their creation mode (e.g. a
      644 file grants the other user read but not write); the tick upgrades
      entries to `rw-` and clears display-only group-x bits that confuse
      VCS exec-bit tracking. Owner-x bits are never touched, so legit
      scripts keep working and stay consistently flagged. Do NOT list huge
      media trees here — the walk is cheap only on small dirs.
    '';
    example = {
      "/home/toyvo/nixcfg" = [
        361
        1000
      ];
    };
  };

  config =
    let
      continuous = config.systemd.tmpfiles.generateRulesContinuous;
      # Shared normalization body for the timer: re-assert file entries +
      # mask (same semantics as the one-shot's file pass). Owner-x bits are
      # untouched; directories are untouched (they need x for traversal).
      fileAcl = uids: lib.concatMapStringsSep "," (uid: "u:${toString uid}:rw-") uids;
      continuousScript = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (directory: uids: ''
          if [ -d "${directory}" ]; then
            find "${directory}" -type f -exec ${pkgs.acl}/bin/setfacl -m m::rw-,${fileAcl uids} {} + || true
          fi
        '') continuous
      );
    in
    lib.mkIf (cfg != { }) {
      # Access ACLs on the directories themselves + default ACLs for inheritance.
      # IMPORTANT: systemd-tmpfiles a+ rules REPLACE the entire ACL via acl_set_file().
      # If multiple a+ rules target the same path, the last one wins and wipes previous
      # entries. We must generate a SINGLE a+ (and A+) rule per directory that includes
      # ALL users, not one rule per user.
      systemd.tmpfiles.rules = lib.concatLists (
        lib.mapAttrsToList (
          directory: uids:
          let
            userAcls = lib.concatMapStrings (uid: "u:${toString uid}:rwx,") uids;
          in
          [
            "a+ ${directory} - - - - ${userAcls}g::---,m::rwx"
            "A+ ${directory} - - - - ${userAcls}g::---,m::rwx"
          ]
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
        # Restart whenever generateRules changes so existing files get ACLs fixed
        # after tmpfiles rules are updated.
        restartTriggers = [
          (builtins.toJSON cfg)
          (builtins.toJSON continuous)
        ];
        script = lib.concatStringsSep "\n" (
          lib.concatLists (
            lib.mapAttrsToList (
              directory: uids:
              map (uid: ''
                if [ -d "${directory}" ]; then
                  find "${directory}" -type d -exec ${pkgs.acl}/bin/setfacl -m m::rwx,u:${toString uid}:rwx {} + || true
                  find "${directory}" -type f -exec ${pkgs.acl}/bin/setfacl -m m::rw-,u:${toString uid}:rw- {} + || true
                  find "${directory}" -type d -exec ${pkgs.acl}/bin/setfacl -d -m m::rwx,u:${toString uid}:rwx {} + || true
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

      # Timer re-asserting file entries + display-clean mask under continuous
      # dirs between boots (same semantics as the one-shot's file pass).
      systemd.services.apply-generated-acls-continuous = lib.mkIf (continuous != { }) {
        description = "Normalize ACLs under generateRulesContinuous dirs";
        serviceConfig.Type = "oneshot";
        script = continuousScript;
      };
      systemd.timers.apply-generated-acls-continuous = lib.mkIf (continuous != { }) {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:0/5";
          Persistent = true;
          RandomizedDelaySec = "60";
        };
      };
    };
}
