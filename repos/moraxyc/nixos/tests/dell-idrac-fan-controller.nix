{
  lib,
  pkgs,
}:

let
  mockIpmitool = pkgs.writeShellScriptBin "ipmitool" ''
    set -euo pipefail
    ${lib.getExe' pkgs.util-linux "logger"} -t mock-ipmitool "args=$*"
    case "$*" in
      *" fru"*)
        printf '%s\n' \
          'FRU Device Description : Builtin FRU Device (ID 0)' \
          ' Product Manufacturer  : DELL' \
          ' Product Name          : PowerEdge R730'
        ;;
      *" mc info"*)
        printf '%s\n' \
          'Firmware Revision         : 2.86'
        ;;
      *" sdr type temperature"*)
        printf '%s\n' \
          'Inlet Temp       | 04h | ok  |  7.1 | 22 degrees C' \
          'Temp             | 0Eh | ok  |  3.1 | 40 degrees C' \
          'Exhaust Temp     | 01h | ok  |  7.1 | 30 degrees C'
        ;;
      *" chassis power status"*)
        echo "Chassis Power is on"
        ;;
      *" raw "*)
        exit 0
        ;;
      *)
        echo "Unexpected ipmitool args: $*" >&2
        exit 1
        ;;
    esac
  '';

  mockSensors = pkgs.writeShellScriptBin "sensors" ''
    printf '%s\n' \
      'coretemp-isa-0000' \
      'Adapter: ISA adapter' \
      'Package id 0:' \
      '  temp1_input: 40.000' \
      '  temp1_max: 65.000' \
      '  temp1_crit: 75.000'
  '';

  testPkg = pkgs.dell-idrac-fan-controller.override {
    ipmitool = mockIpmitool;
    lm_sensors = mockSensors;
  };
in
pkgs.testers.runNixOSTest {
  name = "dell-idrac-fan-controller";

  nodes = {
    local = _: {
      imports = [ ../modules/services/hardware/dell-idrac-fan-controller.nix ];

      systemd.services.create-fake-ipmi-device = {
        before = [ "dell-idrac-fan-controller.service" ];
        requiredBy = [ "dell-idrac-fan-controller.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          touch /dev/ipmi0
          chmod 0600 /dev/ipmi0
        '';
      };

      services.dell-idrac-fan-controller = {
        enable = true;
        package = testPkg;
        settings = {
          IDRAC_HOST = "local";
          FAN_SPEED = 10;
          CHECK_INTERVAL = "1s";
        };
      };
    };

    remote = _: {
      imports = [ ../modules/services/hardware/dell-idrac-fan-controller.nix ];

      services.dell-idrac-fan-controller = {
        enable = true;
        package = testPkg;
        environmentFile = pkgs.writeText "dell-idrac-fan-controller.env" ''
          IDRAC_HOST=192.0.2.10
          IDRAC_USERNAME=root
          IDRAC_PASSWORD=calvin
        '';
        settings = {
          FAN_SPEED = 10;
          HIGH_FAN_SPEED = 50;
          CPU_TEMPERATURE_THRESHOLD = 70;
          CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION = 30;
          CHECK_INTERVAL = "1s";
          MAXIMUM_IPMI_UNREACHABLE_DURATION = null;
          DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE = true;
        };
      };
    };
  };

  testScript = ''
    start_all()

    local.wait_for_unit("dell-idrac-fan-controller.service")
    local.wait_until_succeeds("test -e /run/dell-idrac-fan-controller/heartbeat")
    local.wait_until_succeeds("journalctl -t mock-ipmitool | grep -q 'raw 0x30 0x30 0x02 0xff 0x0a'")

    local_logs = local.succeed("journalctl -u dell-idrac-fan-controller.service --no-pager")
    assert "CPU temperature threshold: 65°C" in local_logs, local_logs
    assert "Could not write" not in local_logs, local_logs

    local.succeed("systemctl stop dell-idrac-fan-controller.service")
    local.wait_until_succeeds(
        "journalctl -u dell-idrac-fan-controller.service --no-pager | "
        "grep -q 'Dell default dynamic fan control profile applied for safety'"
    )
    local.succeed("journalctl -t mock-ipmitool | grep -q 'raw 0x30 0x30 0x01 0x01'")

    remote.wait_for_unit("dell-idrac-fan-controller.service")
    remote.wait_until_succeeds("test -e /run/dell-idrac-fan-controller/heartbeat")
    remote.wait_until_succeeds("journalctl -t mock-ipmitool | grep -q 'lanplus -H 192.0.2.10 -U root -E'")
    # 40C halfway between 30C..70C ramps 10%..50% -> 20% (0x14)
    remote.wait_until_succeeds("journalctl -t mock-ipmitool | grep -q 'raw 0x30 0x30 0x02 0xff 0x14'")

    remote_logs = remote.succeed("journalctl -u dell-idrac-fan-controller.service --no-pager")
    assert "iDRAC unreachable escalation: Disabled" in remote_logs, remote_logs
    assert "calvin" not in remote_logs, remote_logs
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
