{pkgs, ...}: {
  services = {
    xserver = {
      enable = true;
      excludePackages = [pkgs.xterm];
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };

  console.keyMap = "trq";

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
  ];

  environment.systemPackages = with pkgs; [
    kde-rounded-corners
  ];
}
