{
  config,
  lib,
  pkgs,
  ...
}:

let
  enabledNixosServices = lib.attrsets.mapAttrsToList (name: _value: name) (
    lib.attrsets.filterAttrs (
      name: value: value != "enable" && name != "restic" && value ? enable && value.enable
    ) config.homelab.services
  );

  monitoredServices = lib.lists.flatten (
    lib.lists.forEach enabledNixosServices (
      x:
      let
        svc = config.homelab.services.${x};
      in
      svc.monitoredServices or [ x ]
    )
  );

  networkInterfaceLines = lib.concatStrings (
    lib.forEach config.homelab.motd.networkInterfaces (iface: ''
      ${
        if iface == "" then
          ''
            NETDEV=$(ip -o route get 1.1.1.1 | awk '{print $5; exit}')
          ''
        else
          ''
            NETDEV=${iface}
          ''
      }
      printf "$BOLD  * %-20s$ENDCOLOR %s\n" "IPv4 $NETDEV" "$(ip -4 addr show "$NETDEV" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)"
    '')
  );

  serviceStatusLines = lib.concatStrings (
    lib.forEach monitoredServices (svc: ''
      get_service_status "${svc}"
    '')
  );

  motd = pkgs.writeShellScriptBin "motd" ''
        #! ${pkgs.bash}/bin/bash
        set -u
        set -o pipefail

        source /etc/os-release

        RED="\e[31m"
        GREEN="\e[32m"
        YELLOW="\e[33m"
        BOLD="\e[1m"
        ENDCOLOR="\e[0m"

        LOAD1="$(awk '{print $1}' /proc/loadavg)"
        LOAD5="$(awk '{print $2}' /proc/loadavg)"
        LOAD15="$(awk '{print $3}' /proc/loadavg)"

        MEMORY="$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100 / $2 }')"

        HOUR="$(date +"%H")"
        if [ "$HOUR" -lt 12 ] && [ "$HOUR" -ge 0 ]; then
          TIME="morning"
        elif [ "$HOUR" -lt 17 ] && [ "$HOUR" -ge 12 ]; then
          TIME="afternoon"
        else
          TIME="evening"
        fi

        uptime_seconds="$(cut -f1 -d. /proc/uptime)"
        upDays=$((uptime_seconds / 60 / 60 / 24))
        upHours=$((uptime_seconds / 60 / 60 % 24))
        upMins=$((uptime_seconds / 60 % 60))
        upSecs=$((uptime_seconds % 60))

        get_service_status() {
          local service="$1"
          local status

          status="$(systemctl is-active "$service" 2>/dev/null || true)"
          if [ "$status" = "active" ]; then
            printf "$GREEN• $ENDCOLOR%-50s $GREEN[active]$ENDCOLOR\n" "$service"
          elif [ "$status" = "failed" ]; then
            printf "$RED• $ENDCOLOR%-50s $RED[failed]$ENDCOLOR\n" "$service"
          else
            printf "$YELLOW• $ENDCOLOR%-50s $YELLOW[unknown]$ENDCOLOR\n" "$service"
          fi
        }

        printf "$BOLD Welcome to $(hostname)!$ENDCOLOR\n"
        printf "\n"
    ${networkInterfaceLines}
        printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Release" "$PRETTY_NAME"
        printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Kernel" "$(uname -rs)"
        printf "\n"
        printf "$BOLD  * %-20s$ENDCOLOR %s\n" "CPU usage" "$LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)"
        printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Memory" "$MEMORY"
        printf "$BOLD  * %-20s$ENDCOLOR %s\n" "System uptime" "$upDays days $upHours hours $upMins minutes $upSecs seconds"

        printf "\n"
        printf "$BOLD Service status$ENDCOLOR\n"
    ${serviceStatusLines}

        if command -v ${lib.getExe pkgs.zmx} &> /dev/null && [[ -z "''${ZMX_SESSION:-}" ]]; then
          count="$(${lib.getExe pkgs.zmx} ls --short 2>/dev/null | wc -l)"
          if [[ "$count" -gt 0 ]]; then
            echo "${lib.getExe pkgs.zmx}: $count session(s) active — \`zmx-select\` to attach" >&2
          fi
        fi
  '';
in
{
  options.homelab.motd = {
    enable = lib.mkEnableOption "motd Greeting";

    networkInterfaces = lib.mkOption {
      description = "Network interfaces to monitor";
      type = lib.types.listOf lib.types.str;
      default = [ "" ];
    };
  };

  config = lib.mkIf config.homelab.motd.enable {
    environment.systemPackages = [ motd ];

    environment.interactiveShellInit = ''
      ${motd}/bin/motd
    '';
  };
}
