{ lib
, config
, ...
}:
let
  cfg = config.systemd.bindMounts;
in
{
  options.systemd.bindMounts = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    example = {
      "/var/lib/docker" = "/mnt/docker";
    };
  };

  config.systemd.mounts = map
    (mount:
      let
        where = mount;
        what = cfg.${mount};
      in
      {
        inherit where what;
        enable = true;
        description = "Bind mount ${what} to ${where}";
        wantedBy = [ "multi-user.target" ];
        options = "bind";
      })
    (builtins.attrNames cfg);
}
