# Non-module dependencies (`importApply`)
{ pkgs, ... }:

# Service module
{
  lib,
  config,
  options,
  ...
}:
let
  inherit (builtins) concatStringsSep;

  inherit (lib)
    escapeShellArg
    getExe
    mkOption
    optionalAttrs
    singleton
    ;

  inherit (lib.types)
    bool
    package
    str
    listOf
    ;

  yaml = pkgs.formats.yaml { };

  cfg = config.alertmanager-matrix;
in
{
  # https://nixos.org/manual/nixos/unstable/#modular-services
  _class = "service";

  options.alertmanager-matrix = {
    package = mkOption {
      description = "Package to use for ghostunnel";
      defaultText = "The ghostunnel package that provided this module.";
      type = package;
    };

    addr = mkOption {
      description = "Address to listen on.";
      default = ":4051";
      type = str;
    };

    homeserver = mkOption {
      description = "Homeserver to connect to.";
      default = "http://localhost:8008";
      type = str;
    };

    userId = mkOption {
      description = "User ID to connect with.";
      type = str;
    };

    alertmanager = mkOption {
      description = "Alertmanager to connect to.";
      default = "http://localhost:9093";
      type = str;
    };

    tokenFile = mkOption {
      description = "Token to connect with.";
      type = str;
    };

    rooms = mkOption {
      description = "List of allowed rooms. All rooms are allowed by default.";
      type = listOf str;
      default = [ ];
    };

    messageType = mkOption {
      description = "Message type the bot uses.";
      type = str;
      default = "m.notice";
    };

    logLevel = mkOption {
      description = "Log level.";
      type = str;
      default = "info";
    };

    showLabels = mkOption {
      description = "Show labels of alerts messages.";
      type = bool;
      default = false;
    };

    htmlTemplate = mkOption {
      description = "HTML template for alert messages.";
      type = str;
      default =
        #templ
        ''
          {{ range .Alerts }}
            <font color="{{.StatusString|color}}">
              {{.StatusString|icon}} <b>{{.StatusString|upper}}</b> {{.AlertName}}:
            </font>
            {{.Summary}}
            {{if ne .Fingerprint ""}}
              ({{.Fingerprint}})
            {{end}}
            {{if $.ShowLabels}}
              <br/><b>Labels:</b> <code>{{.LabelString}}</code>
            {{end}}
            <br/>
          {{- end -}}
        '';
    };

    textTemplate = mkOption {
      description = "Plain-text template for alert messages.";
      type = str;
      default =
        #templ
        ''
          {{ range .Alerts }}{{.StatusString|icon}} {{.StatusString|upper}} {{.AlertName}}: {{.Summary}}{{if ne .Fingerprint ``}} ({{.Fingerprint}}){{end}}{{if $.ShowLabels}}, labels: {{.LabelString}}{{end}}
          {{ end -}}'';
    };

    colors = mkOption {
      description = "YAML file with colors for message types.";
      inherit (yaml) type;
      default = {
        alert = "black";
        information = "blue";
        info = "blue";
        warning = "orange";
        critical = "red";
        error = "red";
        resolved = "green";
        silenced = "gray";
      };
    };

    icons = mkOption {
      description = "YAML file with icons for message types.";
      inherit (yaml) type;
      default = {
        alert = "🔔️";
        information = "ℹ️";
        info = "ℹ️";
        warning = "⚠️";
        critical = "🚨";
        error = "🚨";
        resolved = "✅";
        silenced = "🔕";
      };
    };
  };

  config = {
    # no LoadCredential or EnvironmentFile for portability, I guess. No
    # `process.env` yet so I guess this is the supported way?
    process.argv =
      pkgs.writeShellScript "start-alertmanager-matrix"
        # bash
        ''
          ADDR=${escapeShellArg cfg.addr}
          HOMESERVER=${escapeShellArg cfg.homeserver}
          USER_ID=${escapeShellArg cfg.userId}
          ALERTMANAGER=${escapeShellArg cfg.alertmanager}
          MESSAGE_TYPE=${escapeShellArg cfg.messageType}
          LOG_LEVEL=${escapeShellArg cfg.logLevel}
          ROOMS=${concatStringsSep "," cfg.rooms |> escapeShellArg}

          HTML_TEMPLATE=${pkgs.writeText "alertmanager-matrix.html.templ" cfg.htmlTemplate}
          TEXT_TEMPLATE=${pkgs.writeText "alertmanager-matrix.txt.templ" cfg.textTemplate}

          SHOW_LABELS=${if cfg.showLabels then "1" else "0"}

          COLORS=${yaml.generate "colors.yaml" cfg.colors}
          ICONS=${yaml.generate "icons.yaml" cfg.icons}

          TOKEN=$(< ${escapeShellArg cfg.tokenFile})

          export \
            ADDR \
            ALERTMANAGER \
            COLORS \
            HOMESERVER \
            HTML_TEMPLATE \
            ICONS \
            LOG_LEVEL \
            MESSAGE_TYPE \
            ROOMS \
            SHOW_LABELS \
            TEXT_TEMPLATE \
            TOKEN \
            USER_ID

          exec ${getExe cfg.package}
        ''
      |> singleton;
  }
  // optionalAttrs (options ? systemd) {
    systemd.service = {
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";

        # hardening BS
        DynamicUser = true;
        ProtectHome = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
        ProtectKernelLogs = true;
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        PrivateUsers = true;
        ProtectClock = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
