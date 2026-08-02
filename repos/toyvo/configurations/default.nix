inputs: {
  nixosConfigurations = {
    HP-Envy = import ./nixos/HP-Envy inputs;
    HP-ZBook = import ./nixos/HP-ZBook inputs;
    MacBook-Pro-NixOS = import ./nixos/MacBook-Pro inputs;
    nas = import ./nixos/nas inputs;
    oracle-cloud-nixos = import ./nixos/oracle-cloud inputs;
    PineBook-Pro = import ./nixos/PineBook-Pro inputs;
    pixel10a = import ./nixos/pixel10a inputs;
    Protectli = import ./nixos/Protectli inputs;
    router = import ./nixos/router inputs;
    rpi4b4a = import ./nixos/rpi4b4a inputs;
    rpi4b8a = import ./nixos/rpi4b8a inputs;
    rpi4b8b = import ./nixos/rpi4b8b inputs;
    rpi4b8c = import ./nixos/rpi4b8c inputs;
    steamdeck-nixos = import ./nixos/steamdeck inputs;
    Thinkpad = import ./nixos/Thinkpad inputs;
    utm = import ./nixos/utm inputs;
    wsl = import ./nixos/wsl inputs;
  };

  darwinConfigurations = {
    MacBook-Pro = import ./darwin/MacBook-Pro inputs;
    MacMini-M1 = import ./darwin/MacMini-M1 inputs;
  };

  homeConfigurations = {
    "deck@steamdeck" = import ./home/steamdeck inputs;
  };
}
