{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.kampka.profiles.headless;
  common = import ./common.nix { inherit pkgs lib; };

in {

  options.kampka.profiles.headless = {
    enable = mkEnableOption "A minimal profile for a headless system";
  };

  config = mkIf cfg.enable (recursiveUpdate common {

    environment.noXlibs = mkDefault true;

    documentation.enable = mkDefault false;
    documentation.nixos.enable = mkDefault false;

    time.timeZone = mkDefault "UTC";

    boot.vesa = mkDefault false;

    # Since we can't manually respond to a panic, just reboot.
    boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];

    # Being headless, we don't need a GRUB splash image.
    boot.loader.grub.splashImage = null;

    services.openssh.enable = mkDefault true;
    services.fail2ban.enable = mkDefault true;

    services.udisks2.enable = mkDefault false;
    security.polkit.enable = mkDefault false;

    users.extraUsers.root.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYS4rpBGwsybZAixmMAI3Wld5Fk7CshdmeoDKDlt/V3DtbaT44hPqpwzSMxtBVSBrzMhAJYgfdc6g33zKxhQv9ebFjCSEa3LybPSjYDOVk+xbB+Fu9FlzfqOQahCZbP4pbbW8lv+1Tr5oJWmW2ewmlfldgU1doDWx3HExT2/CJvaB/h4Bd4N9SroJXMJMwueU3p877GKX20BvcDCxxKql5nL/8HIriMgWjuFOKS9+/LZ4T0kvNgXMW2N+U9vnTSxmwAeyhSEcJkpb+sTOv+97mOeq0CzhW8WuG212OXENBeULoiGavD8+Y3hcjKLKmxrRdkFZPvZfQRDnUhOzkb6gnnU+RTfcRslmnGMigfn/qOQsezHACpkmypDrsiyeCamrlAtM8SYBjf9lWqP1tKHaXh0BBscCjj09AMDj11dJrBwvk6xfS7GB4JZGGx28GWaYJF0qpSyptDd4BuUFW19/y3+5VFoHj9RgdXlk5z6VTnqV+ulm9FwjYXzd3kl/vrgCBUtaBT9KKrFIbuMTgVwMcnj8bo4G9yc0frXFoibAbcWl0VUaKeehdb1RwgBYOtJhPMcB+jInqMOdaSz/b/eZU63r9NyFAENYLqYabO54Cwkf7YDrCoFWgpmuoGEBHAzCVT4mfDzvxLNt6WmfydxZV/rn13aLm6YK43uQoKlLNUQ== openpgp:0x7B8A6BA5"
    ];

    kampka.services.nixops-auto-upgrade = mkDefault {
      enable = true;
      nixPath = builtins.getEnv "NIX_PATH";
    };

    kampka.services.systemd-failure-email.enable = mkDefault true;

    nix.gc = mkDefault {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  });
}
