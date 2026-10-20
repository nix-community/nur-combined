{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mods.sing-box;
  singBox = cfg.package;
  stateDirectory = "/var/lib/sing-box";
  singBoxConfig = "${stateDirectory}/config.json";
  subscriptionConfig = "${stateDirectory}/subscription.json";
  ovpnDirectory = "/var/lib/ovpn";
  ovpnState = "${ovpnDirectory}/state";
  ovpnCredential = "ovpn.json";
  subscriptionCredential =
    if cfg.subscription.secret != null then cfg.subscription.secret else "subscription";
  localConfig = pkgs.writeText "sing-box-local.json" (
    builtins.toJSON (
      lib.recursiveUpdate (
        (lib.optionalAttrs cfg.tun.enable {
          inbounds = [
            {
              type = "tun";
              tag = "tun-in";
              interface_name = cfg.tun.interfaceName;
              address = cfg.tun.address;
              auto_route = true;
              auto_redirect = true;
            }
          ];
        })
        // {
          route.auto_detect_interface = true;
          services = lib.optionals cfg.dashboard.enable [
            {
              type = "api";
              tag = "local-api";
              listen = "127.0.0.1";
              listen_port = cfg.dashboard.port;
              access_control_allow_origin = [
                "http://localhost:${toString cfg.dashboard.port}"
                "http://127.0.0.1:${toString cfg.dashboard.port}"
              ];
              dashboard = {
                enabled = true;
                path = "${stateDirectory}/dashboard";
              };
            }
          ];
        }
      ) cfg.settings
    )
  );
  # systemd reads root-owned vaultix secrets before dropping privileges.
  credentials =
    lib.optional (cfg.subscription.secret != null)
      "${subscriptionCredential}:${config.vaultix.secrets.${cfg.subscription.secret}.path}"
    ++ lib.optional cfg.ovpn.enable "${ovpnCredential}:${
      config.vaultix.secrets.${cfg.ovpn.secret}.path
    }";
  configService = {
    Type = "oneshot";
    User = "sing-box";
    Group = "sing-box";
    StateDirectory = "sing-box";
    StateDirectoryMode = "0700";
    UMask = "0077";
    LoadCredential = credentials;
  };
  prepareSingBoxConfig = pkgs.writeShellScript "prepare-sing-box-config" ''
    set -euo pipefail
    umask 077
    exec 9>${stateDirectory}/config.lock
    ${pkgs.util-linux}/bin/flock -x 9
    enabled=false
    ${lib.optionalString cfg.ovpn.enable ''
      case "$(cat ${ovpnState} 2>/dev/null || echo ${cfg.ovpn.defaultState})" in
        on) enabled=true ;;
        off) enabled=false ;;
        *) echo "Invalid OpenVPN state" >&2; exit 1 ;;
      esac
    ''}
    tmp="$(${pkgs.coreutils}/bin/mktemp ${stateDirectory}/config.json.XXXXXX)"
    trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT
    ${pkgs.jq}/bin/jq --exit-status --argjson ovpn "$enabled" \
      --slurpfile local ${localConfig} \
      ${
        if cfg.ovpn.enable then
          ''--slurpfile vpn "$CREDENTIALS_DIRECTORY/${ovpnCredential}"''
        else
          "--argjson vpn '[]'"
      } \
      --from-file ${./sing-box-merge.jq} "$1" > "$tmp"
    ${lib.getExe singBox} check -D ${stateDirectory} -c "$tmp"
    # Only cache a downloaded subscription after the merged config passes check.
    if [ "$1" != ${subscriptionConfig} ]; then
      ${pkgs.coreutils}/bin/mv -fT "$1" ${subscriptionConfig}
    fi
    ${pkgs.coreutils}/bin/mv -fT "$tmp" ${singBoxConfig}
  '';
  updateSingBoxConfig = pkgs.writeShellScript "update-sing-box-config" ''
    set -euo pipefail
    umask 077
    tmp="$(${pkgs.coreutils}/bin/mktemp ${stateDirectory}/subscription.json.XXXXXX)"
    trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT
    # Feed curl's config on stdin, keeping the URL out of argv and the Nix store.
    ${pkgs.jq}/bin/jq --raw-input --slurp --raw-output \
      '"url = " + (rtrimstr("\n") | rtrimstr("\r") | @json)' \
      "$CREDENTIALS_DIRECTORY/${subscriptionCredential}" |
      ${pkgs.curl}/bin/curl --config - \
        --fail --silent --show-error --location \
        --proto '=https' --proto-redir '=https' \
        --connect-timeout 15 --max-time 120 \
        --retry 3 --retry-delay 5 --output "$tmp"
    ${prepareSingBoxConfig} "$tmp"
  '';
  switchOvpn = pkgs.writeShellApplication {
    name = "switch-ovpn";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
      pkgs.util-linux
    ];
    text = ''
      case "$1" in on|off) ;; *) echo "Expected on or off" >&2; exit 2 ;; esac
      exec 8>${ovpnDirectory}/switch.lock
      flock -x 8
      previous="$(cat ${ovpnState})"
      case "$previous" in on|off) ;; *) echo "Invalid previous VPN state" >&2; exit 1 ;; esac
      temporary="$(mktemp ${ovpnDirectory}/state.XXXXXX)"
      trap 'rm -f "$temporary"' EXIT
      set_state() {
        printf '%s\n' "$1" > "$temporary"
        chmod 0644 "$temporary"
        mv -fT "$temporary" ${ovpnState}
      }
      set_state "$1"
      if systemctl restart sing-box-ovpn-apply.service && systemctl restart sing-box.service; then
        echo "OpenVPN setting: $1"
      else
        echo "Applying VPN setting failed; restoring $previous" >&2
        set_state "$previous"
        if ! { systemctl restart sing-box-ovpn-apply.service && systemctl restart sing-box.service; }; then
          echo "Recovery failed; check journalctl -u sing-box-ovpn-apply -u sing-box" >&2
        fi
        exit 1
      fi
    '';
  };
  ovpnCommand = pkgs.writeShellApplication {
    name = "ovpn";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      if [ "$#" -gt 1 ]; then
        echo "Usage: ovpn [on|off|status]" >&2
        exit 2
      fi
      action="''${1:-status}"
      case "$action" in
        on|off)
          if [ "$EUID" -eq 0 ]; then
            systemctl start "ovpn@$action.service"
          else
            /run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl start "ovpn@$action.service"
          fi
          echo "OpenVPN setting: $action"
          ${lib.optionalString cfg.dashboard.enable ''
            if [ "$action" = on ]; then
              echo "Complete SAML login at http://localhost:${toString cfg.dashboard.port}/dashboard/ (Tools > Endpoints)."
            fi
          ''}
          ;;
        status)
          state="$(cat ${ovpnState} 2>/dev/null || echo ${cfg.ovpn.defaultState})"
          echo "OpenVPN setting: $state"
          ${lib.optionalString cfg.dashboard.enable ''
            if [ "$state" = on ]; then
              ${lib.getExe singBox} api --url http://127.0.0.1:${toString cfg.dashboard.port} openvpn status
            fi
          ''}
          ;;
        *) echo "Usage: ovpn [on|off|status]" >&2; exit 2 ;;
      esac
    '';
  };
in
{
  options.mods.sing-box = {
    enable = lib.mkEnableOption "sing-box with a cached subscription and optional OpenVPN overlay";
    package = lib.mkPackageOption pkgs "sing-box" { };
    subscription = {
      secret = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;
        default = null;
        example = "sub1";
        description = "Vaultix secret containing one HTTPS subscription URL.";
      };
      interval = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "4h";
        description = "Subscription refresh interval, in systemd time syntax.";
      };
      onBootSec = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "1min";
        description = "Delay before the first scheduled subscription refresh.";
      };
    };
    ovpn = {
      enable = lib.mkEnableOption "the OpenVPN JSON overlay and ovpn command";
      secret = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "ovpn";
        description = "Vaultix secret containing the offline-generated OpenVPN JSON overlay.";
      };
      defaultState = lib.mkOption {
        type = lib.types.enum [
          "on"
          "off"
        ];
        default = "off";
        description = "Initial VPN state when no persistent state exists.";
      };
    };
    tun = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Replace subscription inbounds with a local TUN inbound.";
      };
      interfaceName = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "sing-box";
        description = "Name of the TUN interface.";
      };
      address = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "172.19.0.1/30"
          "fdfe:dcba:9876::1/126"
        ];
        description = "IPv4 and IPv6 prefixes assigned to the TUN interface.";
      };
    };
    dashboard = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the loopback API and dashboard for OpenVPN SAML login.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 9090;
        description = "Loopback port used by the API, dashboard and ovpn status.";
      };
    };
    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.json { }).type;
      };
      default = { };
      example = {
        log.level = "info";
      };
      description = ''
        Non-secret JSON settings merged recursively over the module defaults and
        subscription. Arrays replace their subscription counterparts, except
        services which merge by tag. The optional OpenVPN overlay is applied last.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.subscription.secret != null;
        message = "mods.sing-box.subscription.secret must name a vaultix secret when enabled.";
      }
      {
        assertion = config.services.sing-box.settings == { };
        message = "Use mods.sing-box.settings for local settings when mods.sing-box.enable is true.";
      }
    ];
    vaultix.secrets =
      lib.optionalAttrs (cfg.subscription.secret != null) {
        ${cfg.subscription.secret} = { };
      }
      // lib.optionalAttrs cfg.ovpn.enable {
        ${cfg.ovpn.secret} = { };
      };
    services.sing-box = {
      enable = true;
      package = cfg.package;
    };
    environment.systemPackages = lib.optional cfg.ovpn.enable ovpnCommand;
    systemd.tmpfiles.rules = lib.optionals cfg.ovpn.enable [
      "d ${ovpnDirectory} 0755 root root -"
      "f ${ovpnState} 0644 root root - ${cfg.ovpn.defaultState}"
    ];
    systemd.services."ovpn@" = lib.mkIf cfg.ovpn.enable {
      description = "Set the OpenVPN state to %i";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe switchOvpn} %i";
      };
    };
    systemd.services.sing-box-ovpn-apply = lib.mkIf cfg.ovpn.enable {
      description = "Merge the cached subscription with the OpenVPN overlay";
      requires = [ "vaultix-activate.service" ];
      after = [
        "vaultix-activate.service"
        "systemd-tmpfiles-setup.service"
      ];
      serviceConfig = configService // {
        ExecStart = "${prepareSingBoxConfig} ${subscriptionConfig}";
      };
    };
    systemd.services.sing-box = {
      requires = [ "vaultix-activate.service" ];
      after = [ "vaultix-activate.service" ];
      serviceConfig = {
        LoadCredential = credentials;
        UMask = "0077";
        ExecStart = lib.mkForce [
          ""
          "${lib.getExe singBox} -D ${stateDirectory} -c ${singBoxConfig} run"
        ];
        ExecStartPre = [
          (pkgs.writeShellScript "sing-box-ensure-config" ''
            set -euo pipefail
            if [ ! -s ${subscriptionConfig} ]; then
              ${updateSingBoxConfig}
            else
              ${prepareSingBoxConfig} ${subscriptionConfig}
            fi
          '')
        ];
      };
    };
    systemd.services.sing-box-subscription = {
      description = "Update the cached sing-box subscription";
      wants = [ "network-online.target" ];
      requires = [ "vaultix-activate.service" ];
      after = [
        "network-online.target"
        "vaultix-activate.service"
        "systemd-tmpfiles-setup.service"
      ];
      serviceConfig = configService // {
        ExecStart = updateSingBoxConfig;
        ExecStartPost = "+${pkgs.systemd}/bin/systemctl --no-block try-restart sing-box.service";
      };
    };
    systemd.timers.sing-box-subscription = {
      description = "Refresh the sing-box subscription";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = cfg.subscription.onBootSec;
        OnUnitActiveSec = cfg.subscription.interval;
        AccuracySec = "1s";
      };
    };
  };
}
