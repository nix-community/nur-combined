{ inputs, ... }:

{
  imports = [
    "${inputs.self}/system/profiles/xserver.nix"
  ];

  services.xserver = {
    logFile = "/tmp/xserver.log";
    desktopManager.enlightenment.enable = true;
    displayManager.ly = {
      enable = true;
      defaultUser = "bjorn";
      extraConfig = ''
        lang = pt
        asterisk = u
      '';
    };
  };
}
