{ localFlake, withSystem }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.peerbanhelper;
in
{
  options.services.peerbanhelper = {
    enable = lib.mkEnableOption "Enable PeerBanHelper";

    package = lib.mkOption {
      type = lib.types.package;
      default = withSystem pkgs.stdenv.hostPlatform.system (
        { config, ... }: config.packages.peerbanhelper
      );
      defaultText = lib.literalMD "`packages.peerbanhelper` from the shirok1/flakes flake";
      description = "The peerbanhelper package to use.";
    };

    jrePackage = lib.mkPackageOption pkgs "jre" { };

    jvmOptions = lib.mkOption {
      description = ''
        Extra command line options for the JVM running languagetool.
        More information can be found here: <https://docs.oracle.com/en/java/javase/19/docs/specs/man/java.html#standard-options-for-java>
      '';
      default = [ ];
      type = lib.types.listOf lib.types.str;
      example = [
        "-Xmx512m"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.peerbanhelper = {
      description = "PeerBanHelper";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = rec {
        ExecStart = ''
          ${cfg.jrePackage}/bin/java \
            -Djdk.attach.allowAttachSelf=true -Dsun.net.useExclusiveBind=false \
            -Dpbh.release=shirok1/flakes \
            -Dpbh.datadir=/var/lib/${StateDirectory} \
            ${toString cfg.jvmOptions} \
            -jar ${cfg.package}/share/java/PeerBanHelper.jar
        '';
        StateDirectory = "peerbanhelper";
        WorkingDirectory = "/var/lib/${StateDirectory}";
        Restart = "on-failure";
        DynamicUser = true;
      };
    };
  };
}
