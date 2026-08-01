{
  device = {
    system = "x86_64-linux";
    hostname = "archimedes";
    profile = "laptop";
    openpgp.enable = true;
    users = [
      {
        name = "iamanaws";
        groups = [
          "wheel"
          "input"
        ];
        sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvjMCx6qhx8/wWEuALzeQ5PTX+0oq8o5Le0MAmvg97p iamanaws@archimedes";
      }
    ];
    compositors = [ "hyprland" ];
    stateVersion = "24.11";
    timezone = "America/Tijuana";
    locale = "en_US.UTF-8";
  };
}
