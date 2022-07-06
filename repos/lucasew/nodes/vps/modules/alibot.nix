{pkgs, cfg, config, lib, ...}:
let
  inherit (pkgs) callPackage dotenv fetchFromGitHub;
  inherit (lib) mkEnableOption types mkOption mkIf;
  inherit (cfg) rootPath;

  module = config.vps.alibot;
  alibot = callPackage "${
    fetchFromGitHub {
      url = "ssh://git@github.com/lucasew/alibot";
      rev = "5bf5a883f7e600905280a9ea4a445f575e94a04d";
      sha256 = lib.fakeSha256;
    }
  }/package.nix" {};
in
{
  options = {
    vps.alibot = {
      enable = mkEnableOption "Enable alibot";
      secretsDotenv = mkOption {
        type = types.str;
        description = "a dotenv file with a BOT_TOKEN variable";
        default = "${rootPath}/secrets/alibot.env";
      };
      stateStore = mkOption {
        type = types.str;
        description = "where to save the state file";
        default = "/persist/alibot.json";
      };
    };
  };
  config = mkIf module.enable {
    systemd = {
      services.alibot = {
        enable = true;
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${dotenv}/bin/dotenv '@${module.secretsDotenv}' -- ${alibot}/bin/alibot -d '${module.stateStore}'";
        };
        wantedBy = [
          "default.target"
        ];
      };
    };
  };
}
