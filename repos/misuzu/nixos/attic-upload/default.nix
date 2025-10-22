{ config, lib, pkgs, ... }:
let
  cfg = config.services.attic-upload;
in
{
  options = {
    services.attic-upload = {
      enable = lib.mkEnableOption "Attic upload";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.attic-client;
        defaultText = "pkgs.attic-client";
        example = lib.literalExpression "pkgs.attic-client";
        description = lib.mdDoc ''
          Attic package.
        '';
      };
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = lib.mdDoc ''
          List of additional arguments to pass to the `attic push`.
        '';
      };
      atticConfigFile = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc ''
          File which would be symlinked to ~/.config/attic/config.toml
        '';
      };
      cache = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc ''
          The cache to push to.
          This can be either `servername:cachename` or `cachename` when using the default server.
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    nix.settings.post-build-hook = pkgs.writeShellScript "attic-upload" ''
      set -eu
      set -f # disable globbing

      # skip push if the declarative job spec
      OUT_END=$(echo ''${OUT_PATHS: -10})
      if [ "$OUT_END" == "-spec.json" ]; then
      exit 0
      fi

      export IFS=' '
      echo $OUT_PATHS | ${pkgs.socat}/bin/socat - UNIX-CLIENT:/run/attic-upload-queue/socket || true
    '';
    systemd.services.attic-upload-queue = {
      description = "Attic upload queue";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        mkdir -p ~/.config/attic
        ln -sf ''${CREDENTIALS_DIRECTORY}/attic-config-toml ~/.config/attic/config.toml
        ${pkgs.socat}/bin/socat UNIX-LISTEN:/run/attic-upload-queue/socket,mode=600,fork - | while read -r
        do
          echo "Processing $REPLY"
          while ! ${cfg.package}/bin/attic push ${cfg.cache} ${lib.concatStringsSep " " cfg.extraArgs} $REPLY
          do
            echo "Retry $REPLY"
          done
        done
      '';
      environment = config.networking.proxy.envVars // {
        HOME = "/var/lib/attic-upload-queue";
      };
      serviceConfig = {
        LoadCredential = [
          "attic-config-toml:${cfg.atticConfigFile}"
        ];
        DynamicUser = true;
        Restart = "always";
        RuntimeDirectory = "attic-upload-queue";
        StateDirectory = "attic-upload-queue";
        WorkingDirectory = "/var/lib/attic-upload-queue";
      };
    };
  };
}
