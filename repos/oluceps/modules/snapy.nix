{
  pkgs,
  config,
  lib,
  utils,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    nameValuePair
    mkIf
    ;

  cfg = config.services.snapy;
  inherit (utils.systemdUtils.unitOptions) unitOption;
in
{
  options.services.snapy = {
    instances = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption { type = types.str; };
            source = mkOption {
              type = types.str;
              default = "/persist";
            };
            timerConfig = mkOption {
              type = types.nullOr (types.attrsOf unitOption);
              default = {
                OnCalendar = "daily";
              };
            };
            keep = mkOption {
              type = types.str;
              default = "3hr";
            };
          };
        }
      );
      default = [ ];
    };
  };
  config = mkIf (cfg.instances != [ ]) {

    systemd.timers = lib.foldr (
      s: acc:
      acc
      // {
        "snapy-${s.name}" = {
          description = "snap task ${s.name}";
          wantedBy = [ "timers.target" ];
          timerConfig = lib.mapAttrs' (name: value: nameValuePair (lib.capitalize name) value) s.timerConfig;
        };
      }
    ) { } cfg.instances;

    systemd.services = lib.foldr (
      s: acc:
      acc
      // {
        "snapy-${s.name}" = {
          wantedBy = [ "multi-user.target" ];
          description = "${s.name} snapy daemon";
          serviceConfig = {
            User = "root";
            ExecStart =
              let
                btrfs = lib.getExe' pkgs.btrfs-progs "btrfs";
              in
              pkgs.lib.getExe (
                pkgs.nuenv.writeScriptBin {
                  name = "snapy";
                  script = ''
                    const date_format = "%Y-%m-%d_%H:%M:%S%z"

                    # take snapshot
                    let formated_now = date now | format date $date_format;

                    let snapshot_place = $formated_now | $'${s.source}/.snapshots/($in)'

                    if ($snapshot_place | path exists) { print -e "oops, collision"; exit }

                    let snapshot_dir = $snapshot_place | path dirname

                    $formated_now | ${btrfs} subvol snapshot -r ${s.source} $snapshot_place

                    let latest_place = $snapshot_dir | path join "latest"

                    # link to latest
                    ln -sfn $snapshot_place $latest_place

                    # clean outdated
                    ls ${s.source}/.snapshots | filter { || $in.type != "symlink" } | filter { |i| ((date now) - ($i.name | path basename | into datetime --format $date_format)) > ${s.keep} } | each { |d| ${btrfs} sub del $d.name }
                  '';
                }
              );
          };
        };
      }
    ) { } cfg.instances;
  };
}
