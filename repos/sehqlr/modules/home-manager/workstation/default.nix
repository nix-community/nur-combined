{ config, pkgs, ... }: {
  services.kanshi.profiles."workstation" = {
    outputs = [
      {
        criteria = "HDMI-A-1";
        position = "0,0";
      }
      {
        criteria = "VGA-1";
        position = "1920,0";
      }
    ];
  };
}
