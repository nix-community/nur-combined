{ pkgs, config, lib, ... }:

let
  cfg = config.services.matrix-media-repo;
in
{
  options.services.matrix-media-repo = {
    enable = lib.mkEnableOption "matrix-media-repo";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nur.repos.linyinfeng.matrix-media-repo;
      defaultText = "pkgs.nur.repos.linyinfeng.matrix-media-repo";
      description = lib.mkDoc ''
        matrix-media-repo derivation to use.
      '';
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      description = lib.mkDoc ''
        Path to configuration file.

        See <https://docs.t2bot.io/matrix-media-repo/configuration/index.html>.
      '';
    };
    extraOptions = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = ''
        Extra options passed to matrix-media-repo command line.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.matrix-media-repo = {
      description = "Matrix media repo";
      script = ''
        export CONFIG_FILE="$CREDENTIALS_DIRECTORY/config.yaml"

        "${cfg.package}/bin/media_repo" -config "$CONFIG_FILE" \
          ${lib.escapeShellArgs cfg.extraOptions}
      '';
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "matrix-media-repo";
        WorkingDirectory = "/var/lib/matrix-media-repo";
        LoadCredential = [
          "config.yaml:${cfg.configFile}"
        ];
      };
      path = with pkgs; [
        imagemagick
      ];
      wantedBy = [ "multi-user.target" ];
    };
    environment.systemPackages = [
      cfg.package
    ];
  };
}
