{ ... }:
{
  services.keybase.enable = true;
  services.kbfs = {
    enable = true;
    mountPoint = ".local/keybase";
  };
}
