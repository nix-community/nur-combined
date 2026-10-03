{ pkgs, config, ... }: {
  boot.kernelModules = [ "sg" ]; # SG = scsi generic, what allows pass-thru of the optical drive to wine with model# and such

  users.users.ripper = {
    isNormalUser = true;
    extraGroups = [
      "vboxusers"
      "dialout"
    ];

    openssh.authorizedKeys.keys = config.users.users.shelvacu.openssh.authorizedKeys.keys;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };
}
