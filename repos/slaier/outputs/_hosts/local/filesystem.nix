{
  imports = [ ./disko.nix ];

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/etc/ssh" = {
    depends = [ "/persist" ];
    neededForBoot = true;
  };
  environment.persistence."/persist" = {
    directories = [
      "/etc/ssh"
      "/var"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.nixos = {
      directories = [
        ".arduino15"
        ".arduinoIDE"
        ".cache"
        ".cmake"
        ".config"
        ".gemini"
        ".local"
        ".mozilla"
        ".nali"
        ".pki"
        ".platformio"
        ".ssh"
        ".steam"
        ".wokwi"
        "repos"
      ];
    };
  };
}
