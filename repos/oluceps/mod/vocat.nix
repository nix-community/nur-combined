{ inputs, ... }:
{
  flake.modules.nixos.vocat =
    { pkgs, ... }:
    {

      imports = [ inputs.vocat.nixosModules.default ];

      boot.kernelModules = [
        "option"
        "usb_wwan"
      ];

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2ca3", ATTR{idProduct}=="4006", RUN+="${pkgs.bash}/bin/sh -c 'echo 2ca3 4006 > /sys/bus/usb-serial/drivers/option1/new_id'"
      '';
      services.vocat = {
        enable = true;
        config = {
          address = "[::]:7575";
          database_path = "/var/lib/vocat/vocat.db";
          session_ttl = "24h";
          secure_cookies = false;
          shutdown_timeout = "10s";
          max_request_body_bytes = 1048576;
        };
      };

    };
}
