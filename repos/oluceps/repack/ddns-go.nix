{ reIf, ... }:
reIf {
  services.ddns-go = {
    enable = true;
  };
}
