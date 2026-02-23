{ ... }:
{
  networking.hostName = "wsl";
  profiles = {
    defaults.enable = true;
  };
  userPresets.toyvo.enable = true;
  wsl.enable = true;
  wsl.defaultUser = "toyvo";
}
