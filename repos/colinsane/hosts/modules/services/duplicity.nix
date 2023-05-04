# docs: https://search.nixos.org/options?channel=21.11&query=duplicity
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.sane.services.duplicity;
in
{
  options = {
    sane.services.duplicity.enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # we need this mostly because of the size of duplicity's cache
    # TODO: move to cryptClearOnBoot and update perms
    sane.persist.sys.plaintext = [ "/var/lib/duplicity" ];

    services.duplicity.enable = true;
    services.duplicity.targetUrl = "$DUPLICITY_URL";
    # format: PASSPHRASE=<cleartext> \n DUPLICITY_URL=b2://...
    # two sisters
    # PASSPHRASE: remote backups will be encrypted using this passphrase (using gpg)
    # DUPLICITY_URL: b2://$key_id:$app_key@$bucket
    # create key with: backblaze-b2 create-key --bucket uninsane-host-duplicity uninsane-host-duplicity-safe listBuckets,listFiles,readBuckets,readFiles,writeFiles
    #   ^ run this until you get a key with no forward slashes :upside_down:
    #   web-created keys are allowed to delete files, which you probably don't want for an incremental backup program
    #   you need to create a new application key from the web in order to first get a key which can create new keys (use env vars in the above command)
    # TODO: s/duplicity_passphrase/duplicity_env/
    services.duplicity.secretFile = config.sops.secrets.duplicity_passphrase.path;
    # NB: manually trigger with `systemctl start duplicity`
    services.duplicity.frequency = "daily";

    services.duplicity.extraFlags = [
      # without --allow-source-mismatch, duplicity will abort if you change the hostname between backups
      "--allow-source-mismatch"

      # includes/exclude ordering matters, so we explicitly control it here.
      # the first match decides a file's treatment. so here:
      # - /nix/persist/home/colin/tmp is excluded
      # - *other* /nix/persist/ files are included by default
      # - anything else under `/` are excluded by default
      "--exclude" "/nix/persist/home/colin/dev/home-logic/coremem/out"  # this can reach > 1 TB
      "--exclude" "/nix/persist/home/colin/use/iso"  # might want to re-enable... but not critical
      "--exclude" "/nix/persist/home/colin/.local/share/sublime-music"  # music cache. better to just keep the HQ sources
      "--exclude" "/nix/persist/home/colin/.local/share/Steam"  # can just re-download games
      "--exclude" "/nix/persist/home/colin/.bitmonero/lmdb"  # monero blockchain
      "--exclude" "/nix/persist/home/colin/.rustup"
      "--exclude" "/nix/persist/home/colin/ref"  # publicly available data: no point in duplicating it
      "--exclude" "/nix/persist/home/colin/tmp"
      "--exclude" "/nix/persist/home/colin/Videos"
      "--exclude" "/nix/persist/var/lib/duplicity"  # don't back up our own backup state!
      "--include" "/nix/persist"
      "--exclude" "/"
    ];

    # set this for the FIRST backup, then remove it to enable incremental backups
    #   (that the first backup *isn't* full i think is a defect)
    # services.duplicity.fullIfOlderThan = "always";

    systemd.services.duplicity.serviceConfig = {
      # rate-limit the read bandwidth in an effort to thereby prevent net upload saturation
      # this could perhaps be done better by adding a duplicity config option to replace the binary with `trickle`
      IOReadBandwidthMax = [
        "/dev/sda1 5M"
        "/dev/nvme0n1 5M"
        "/dev/mmc0 5M"
      ];
    };

    # based on <nixpkgs:nixos/modules/services/backup/duplicity.nix>  with changes:
    # - remove the cleanup step: API key doesn't have delete perms
    # - don't escape the targetUrl: it comes from an env var set in the secret file
    systemd.services.duplicity.script = let
      cfg = config.services.duplicity;
      target = cfg.targetUrl;
      extra = escapeShellArgs ([ "--archive-dir" "/var/lib/duplicity" ] ++ cfg.extraFlags);
      dup = "${pkgs.duplicity}/bin/duplicity";
    in lib.mkForce ''
      set -x
      # ${dup} cleanup ${target} --force ${extra}
      # ${lib.optionalString (cfg.cleanup.maxAge != null) "${dup} remove-older-than ${lib.escapeShellArg cfg.cleanup.maxAge} ${target} --force ${extra}"}
      # ${lib.optionalString (cfg.cleanup.maxFull != null) "${dup} remove-all-but-n-full ${builtins.toString cfg.cleanup.maxFull} ${target} --force ${extra}"}
      # ${lib.optionalString (cfg.cleanup.maxIncr != null) "${dup} remove-all-inc-of-but-n-full ${toString cfg.cleanup.maxIncr} ${target} --force ${extra}"}
      exec ${dup} ${if cfg.fullIfOlderThan == "always" then "full" else "incr"} ${lib.escapeShellArg cfg.root} ${target} ${lib.escapeShellArgs ([]
        ++ concatMap (p: [ "--include" p ]) cfg.include
        ++ concatMap (p: [ "--exclude" p ]) cfg.exclude
        ++ (lib.optionals (cfg.fullIfOlderThan != "never" && cfg.fullIfOlderThan != "always") [ "--full-if-older-than" cfg.fullIfOlderThan ])
        )} ${extra}
    '';
  };
}
