{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.ip-to-usb;
  account = "IP-to-USB";  # TODO Maybe use hostname instead and this as issuer
  issuer = "NixOS";
  qrCodeContent = ''
    otpauth://totp/${issuer}:${account}?issuer=${issuer}&algorithm=SHA1&digits=6&secret=${cfg.psk}&period=30
  '';
  script = pkgs.writeShellScriptBin "ip-to-usb" ''
    # TODO Check that there are any arguments at all
    # TODO Check that $1 is a sensible block device name

    # Make mount/umount and ip command available
    export PATH="${pkgs.utillinux}/bin:${pkgs.iproute}/bin:$PATH"
    date >> ${cfg.logPath}
    echo "Plugged in device $1" >> ${cfg.logPath}

    MOUNTPOINT=$(mktemp -d)

    MOUNTED=false
    if mount "/dev/$1" "$MOUNTPOINT"; then
      MOUNTED=true
    fi

    # Truncate file
    echo -n "" > "$MOUNTPOINT/ip-address"

    if [ ! -f "$MOUNTPOINT/ip-to-usb.conf" ]; then
        echo "No ip-to-usb.conf file on /dev/$1" >> ${cfg.logPath}
        exit 1
    fi

    ${if null == cfg.psk then "" else ''
      PSK=$(${pkgs.jq}/bin/jq .psk -r "$MOUNTPOINT/ip-to-usb.conf")
      if [ "$PSK" != "${cfg.psk}" ]; then
        echo "PSK($PSK) isn't valid!" >> ${cfg.logPath}
        echo "PSK($PSK) isn't valid!" >> "$MOUNTPOINT/ip-address"
        exit 2
      fi
    ''}

    ${if null == cfg.twoFactor then "" else ''
      TOTP=$(${pkgs.jq}/bin/jq .totp -r "$MOUNTPOINT/ip-to-usb.conf")
      if [ "${toString (null == cfg.twoFactor)}" = "1" ] && \
         ! ${pkgs.oathToolkit}/bin/oathtool -b ${cfg.psk} "$TOTP" -w 10 --totp=sha1; then
          >&2 echo "TOTP($TOTP) isn't valid!" >> ${cfg.logPath}
          echo "TOTP($TOTP) isn't valid!" >> "$MOUNTPOINT/ip-address"
          exit 3
      fi
    ''}

    ${if cfg.interfaces == [] then ''
      ip address >> "$MOUNTPOINT/ip-address"
      ip address >> ${cfg.logPath}
    '' else ''
      interfaces = "${toString cfg.interfaces}"
      for interface in $interfaces; do
        ip address show dev "$interface" >> "$MOUNTPOINT/ip-address"
        ip address show dev "$interface" >> ${cfg.logPath}
    ''}

    sync
    # Only umount if it was unmounted before (paranoia)
    if [ "$mounted" = true ] ; then
      umount "/dev/$1" 
    fi
    echo "" >> ${cfg.logPath}
  '';
in
{
  ##### interface
  options = {
    services.ip-to-usb = {
      enable = mkEnableOption "ip-to-usb";

      description = ''
        With this module you can securely extract the IP address from a headless device.
        You need to place a single file at the root of the device: ip-to-usb.conf
        If you don't want any authentication this file can be empty.

        Example /mnt/ip-to-usb.conf:
        ```
        {
          "psk": "95bd1daaa85169f1ea505ef29b734812809",
          "totp": "168850"
        }
        ```
      '';

      interfaces = mkOption {
        type = types.listOf types.string;
        default = [];
        description = ''
          Which interfaces to get ip address from.
          If set to an empty list it will be about all devices.
          '';
      };

      logPath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "If not null events will be logged there";
      };

      psk = mkOption {
        type = types.nullOr types.string;
        default = null;
        description = ''
          Nothing wil be written to the device if it doesn't contain the PSK at .psk
          in the ip-to-usb.conf JSON file which lies at the root.

          If it's null there is no authentication;
        '';
      };

      twoFactor = mkOption {
        type = types.nullOr types.string;
        default = null;
        description = ''
          If it is not null and in base32 form it will be used as TOTP key
          (RFC 6238) to authenticate the thumb drive in addition to the psk

          Should be in the JSON file ip-to-usb.conf at .totp at the root of the device.
        '';
      };
 
      qrCode = mkOption {
        type = types.nullOr types.path;
        default = if cfg.twoFactor != null then "/etc/ip-to-usb_qrcode.png" else null;
        description = ''
          Path where the PNG of a QR code with which you can register the TOTP
          in Google Authenticator.

          According to https://github.com/google/google-authenticator/wiki/Key-Uri-Format
        '';
      };
    };
  };


  ##### implementation
  config = mkIf cfg.enable {
    assertions = [
      # TODO Check if base32 really means RFC 4648 and assert that twoFactor matches
      {
        assertion = !(! isNull cfg.twoFactor && cfg.psk == null);
        message = "`twoFactor` can only be enabled together with `psk`";
      }
      {
        assertion = !(cfg.qrCode != null && cfg.twoFactor == null);
        message = "If you want a QR-Code you have to specify a `twoFactor` key";
      }
    ];

    system.activationScripts.ip-to-usb_qrcode = mkIf (cfg.qrCode != null) ''
      ${pkgs.qrencode}/bin/qrencode -o "${cfg.qrCode}" "${qrCodeContent}"
    '';

    services.udev.extraRules= ''
      KERNEL=="sd[a-z]*[0-9]", SUBSYSTEMS=="usb", ACTION=="add", RUN+="${script}/bin/ip-to-usb %k"
    '';
  };
}
