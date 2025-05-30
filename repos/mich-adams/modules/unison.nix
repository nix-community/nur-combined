{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.unison;

  pairOf =
    t:
    let
      list = types.addCheck (types.listOf t) (l: length l == 2);
    in
    list // { description = list.description + " of length 2"; };

  pairOptions = {
    options = {

      commandOptions = mkOption rec {
        type = with types; attrsOf (either str (listOf str));
        apply = mergeAttrs default;
        default = {
          repeat = "watch";
          sshcmd = "${pkgs.openssh}/bin/ssh";
          ui = "text";
          auto = "true";
          batch = "true";
          log = "false"; # don't log to file, handled by systemd
        };
        description = ''
          Additional command line options as a dictionary to pass to the
          `unison` program.

          Use a list of strings to declare the same option multiple times.

          See
          {manpage}`unison(1)`
          for a list of available options.
        '';
      };

      roots = mkOption {
        type = pairOf types.str;
        example = literalExpression ''
          [
            "/home/user/documents"
            "ssh://remote/documents"
          ]
        '';
        description = ''
          Pair of roots to synchronise.
        '';
      };
    };
  };

  serialiseArg =
    key: val:
    concatStringsSep " " (forEach (toList val) (x: escapeShellArg "-${key}=${escape [ "=" ] x}"));

  serialiseArgs = args: concatStringsSep " " (mapAttrsToList serialiseArg args);

  unitName = name: "unison-pair-${name}";

  makeDefs =
    gen: mapAttrs' (name: pairCfg: nameValuePair (unitName name) (gen name pairCfg)) cfg.pairs;

in
{

  options.services.unison = {
    enable = mkEnableOption "Unison synchronisation";

    package = mkPackageOption pkgs "unison" {
      example = "pkgs.unison.override { enableX11 = false; }";
    };

    stateDirectory = mkOption {
      type = types.path;
      #default = "${config.users.users.michael.home}/unison";
      default = null;
      defaultText = "$XDG_DATA_HOME/unison";
      description = ''
        Unison state directory to use.
      '';
    };

    pairs = mkOption {
      type = with types; attrsOf (submodule pairOptions);
      default = { };
      example = literalExpression ''
        {
          "my-documents" = {
            roots = [
              "/home/user/documents"
              "ssh://remote/documents"
            ];
          };
        }
      '';
      description = ''
        Unison root pairs to keep synchronised.
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.user.services = makeDefs (
      name: pairCfg: {
        description = "Unison pair sync (${name})";
        serviceConfig = {
          CPUSchedulingPolicy = "idle";
          IOSchedulingClass = "idle";
          Environment = [
            "XDG_RUNTIME_DIR='/run/user/$UID'"
            "UNISON='${toString cfg.stateDirectory}'"
          ];
          ExecStart = ''
            ${cfg.package}/bin/unison \
              ${serialiseArgs pairCfg.commandOptions} \
              ${strings.concatMapStringsSep " " escapeShellArg pairCfg.roots}
          '';
        };
        #path = [ cfg.package pkgs.openssh ];
      }
    );

    systemd.user.timers = makeDefs (
      name: pairCfg: {
        description = "Unison pair sync auto-restart (${name})";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Unit = "${unitName name}.service";
          OnActiveSec = 1;
          OnUnitInactiveSec = 60;
        };
      }
    );
  };
}
