{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.qemuVerbatimConfig;
in
{
  options.qemuVerbatimConfig = {
    enable = mkEnableOption "qemuVerbatimConfig module";
    kvmfrDeviceCount = mkOption {
      type = types.ints.unsigned;
      default = 0;
      description = "Number of kvmfr devices. Used for adding kvmfr devices to cgroup_device_acl automatically";
      example = "1";
    };
    extraCgroupDeviceAclList = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of devices to add to cgroup_device_acl";
      example = "[ /dev/input/by-id/KEYBOARD_NAME ]";
    };
  };

  config = mkIf cfg.enable (
    let
      kvmfrDevices =
        if cfg.kvmfrDeviceCount != 0
        then
          builtins.map (x: "/dev/kvmfr${x}")
            (builtins.map builtins.toString (lib.range 0 (cfg.kvmfrDeviceCount - 1)))
        else
          [ ];
      cgroupDeviceAclList = [
        "/dev/null"
        "/dev/full"
        "/dev/zero"
        "/dev/random"
        "/dev/urandom"
        "/dev/ptmx"
        "/dev/kvm"
      ] ++ kvmfrDevices ++ cfg.extraCgroupDeviceAclList;
    in
    {
      virtualisation.libvirtd.qemuVerbatimConfig = ''
        cgroup_device_acl = [${lib.concatMapStringsSep "," (x: "\"${x}\"") cgroupDeviceAclList}]
      '';
    }
  );
}
