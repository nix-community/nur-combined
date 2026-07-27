{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.modules.dev.containers.image-mirroring;
  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "sync.yaml" cfg.settings;
in
{
  ##### interface
  options = {
    modules.dev.containers.image-mirroring = {
      enable = mkEnableOption "Enable container image mirroring service";
      targets = mkOption {
        type = types.listOf types.str;
        example = [ "quay.io/vdemeest" "ghcr.io/vdemeester" ];
        description = lib.mdDoc ''
          A list of targets to sync images to. It will use the same
          sync configuration to push on all.
        '';
      };
      settings = mkOption {
        type = settingsFormat.type;
        default = { };
        example = {
          "docker.io" = {
            "vdemeester/foo" = [ "latest" "bar" ];
          };
          "quay.io" = {
            "buildah/stable" = [ "latest" ];
          };
        };
        description = lib.mdDoc ''
          Configuration of the image to sync, using skopeo-sync.
          See skopeo-sync(1) for the content. 
        '';
      };
    };
  };
  ##### implementation
  config = mkIf cfg.enable {
    systemd.services.container-image-mirroring = {
      description = "Synchronize docker images to a set of targets";
      requires = [ "network-online.target" ];

      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;

      serviceConfig = {
        Type = "oneshot";
        User = "vincent";
        OnFailure = "status-email-root@%.service";
      };

      path = with pkgs; [ skopeo ];
      # ./scripts/docker.mirroring.script.sh;
      script = ''
        BUILDTMPDIR=$(mktemp -d)
        trap 'rm -rf -- "$BUILDTMPDIR"' EXIT


        # Pull to dir first
        skopeo sync --preserve-digests --src yaml --dest dir \
               ${settingsFile} \
               $BUILDTMPDIR

        # Push to targets
        for target in ${lib.strings.concatStringsSep " " cfg.targets}; do
            skopeo sync --preserve-digests --src dir --dest docker \
                   $BUILDTMPDIR \
                   $target
        done
      '';

      after = [ "network-online.target" ];
      # Make it configurable ?
      startAt = "weekly";
    };
  };
}
