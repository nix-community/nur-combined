{lib, config, ...}:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.services.nix-redirect-tmp;
in
{
  options = {
    services.nix-redirect-tmp = {
      enable = mkOption {
        description = "enable build dir redirection for nix";
        type = types.bool;
        default = true;
        example = true;
      };
      location = mkOption {
        description = "Where to redirect the build dir";
        default = "/tmp/nix-build";
        type = types.path;
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.location} 755 root root 0"
    ];
    systemd.services.nix-daemon.environment = { TMPDIR = cfg.location; };
  };
}
