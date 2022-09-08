{ pkgs, utils, config, lib, ... }: with lib; let
  cfg = config.users.chroot;
  mounts = filterAttrs (_: mount: mount.enable) cfg.mounts;
  matchBlock = ''
    Match User ${concatStringsSep "," cfg.users}
      ChrootDirectory ${cfg.root}
  '';
  defaultShell = utils.toShellPath config.users.defaultUserShell;
  shell = pkgs.writeShellScriptBin "root-shell" ''
    if [ -e /sys ]; then
      exec ${pkgs.util-linux}/bin/unshare -c -U -R ${cfg.root} -w "$PWD" ${defaultShell} "$@"
    else
      exec ${defaultShell} "$@"
    fi
  '' // {
    shellPath = "/bin/root-shell";
  };
  bindMountModule = { config, name, ... }: {
    options = {
      enable = mkEnableOption "mount" // {
        default = true;
      };
      source = mkOption {
        type = types.str;
        default = config.target;
      };
      target = mkOption {
        type = types.path;
        default = name;
      };
      type = mkOption {
        type = types.str;
        default = "bind";
      };
      mount = mkOption {
        type = unmerged.type;
      };
    };
    config = {
      mount = mkMerge [
        {
          type = {
            bind = "none";
          }.${config.type} or config.type;
          what = config.source;
          where = cfg.root + config.target;
          unitConfig.RequiresMountsFor = [ (builtins.dirOf config.target) ];
        }
        (mkIf (config.type == "bind") {
          mountConfig.Options = [ "bind" ];
        })
      ];
    };
  };
in {
  options.users.chroot = {
    enable = mkEnableOption "user chroot" // {
      default = cfg.users != [ ];
    };
    root = mkOption {
      type = types.path;
      default = "/run/ssh-root";
    };
    users = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    tmpfs.size = mkOption {
      type = types.str;
      default = "8m";
    };
    openssh.enable = mkEnableOption "ssh ChrootDirectory" // {
      default = true;
    };
    local.enable = mkEnableOption "local chroot" // {
      default = true;
    };
    mounts = mkOption {
      type = with types; attrsOf (submodule bindMountModule);
      default = { };
    };
  };
  config = mkMerge [
    {
      environment = mkIf cfg.local.enable {
        shells = [ shell ];
        systemPackages = [ shell ];
      };
      users = {
        users = mkIf cfg.local.enable (genAttrs cfg.users (name: {
          inherit shell;
        }));
        chroot.mounts = {
          "/dev" = { };
          "/dev/pts" = { };
          "/nix" = { };
          "/run" = { };
          "/var/run" = { };
          "/etc" = { };
          "/usr" = { };
          "/bin" = { };
          "/proc" = {
            type = "proc";
            mount.mountConfig.Options = [ "hidepid=2" ];
          };
          "/tmp" = {
            type = "tmpfs";
            mount.mountConfig.Options = [ "size=${cfg.tmpfs.size}" ];
          };
        };
      };
    }
    (mkIf cfg.enable {
      services.openssh.extraConfig = mkIf cfg.openssh.enable (mkOrder 2000 matchBlock);
      systemd.mounts = mapAttrsToList (_: mount: unmerged.merge mount.mount) mounts
      ++ map (username: {
        type = "none";
        mountConfig.Options = [ "bind" ];
        unitConfig.RequiresMountsFor = mapAttrsToList (_: mount: mount.target) mounts;
        what = config.users.users.${username}.home;
        where = "${cfg.root}/home/${username}";
      }) cfg.users;
      systemd.automounts = map (username: {
        where = "${cfg.root}/home/${username}";
        wantedBy = mkIf cfg.openssh.enable (if config.services.openssh.startWhenNeeded
          then [ "sshd.socket" ]
          else [ "sshd.service" ]);
      }) cfg.users;
    })
  ];
}
