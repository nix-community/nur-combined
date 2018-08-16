{ config, lib, pkgs, ... }:

with lib;

let
  cpupower = config.boot.kernelPackages.cpupower;
in

{
  services.acpid = {
    enable = true;
    handlers = {
      ac-power = {
        event = "ac_adapter/*";
        action = ''
          vals=($1)  # space separated string to array of multiple values
          case ''${vals[3]} in
              00000000)
                  logger 'AC unpluged'
                  echo unplugged >> /tmp/acpi
                  systemctl stop ac-power.target
                  ;;
              00000001)
                  logger 'AC pluged'
                  echo plugged in >> /tmp/acpi
                  systemctl start ac-power.target
                  ;;
              *)
                  logger "Don't know what to do: $4"
                  echo "anything: '$1' '$2' '$3' '$4'" >> /tmp/acpi
                  ;;
          esac
        '';
      };
    };
  };
  systemd.targets.ac-power = {
    description = "A target that is active when connected to AC power.";
  };
  systemd.services.cpufreq-ac = {
    description = "CPU Frequency Governor Setup";
    wantedBy = [ "ac-power.target" ];
    partOf = [ "ac-power.target" ];
    path = [ cpupower pkgs.kmod ];
    unitConfig.ConditionVirtualization = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${cpupower}/bin/cpupower frequency-set -g performance";
      ExecStop = "${cpupower}/bin/cpupower frequency-set -g powersave";
      SuccessExitStatus = "0 237";
    };
  };
}
