{ ... }:
rec {
  fail2ban-rs = ./fail2ban-rs;
  fungi = ./fungi;
  galgamemanager = ./galgamemanager;
  nextppp = ./nextppp;
  reader-server-rs = ./reader-server-rs;
  selector4nix = ./selector4nix;
  system76-scheduler-niri = ./system76-scheduler-niri;

  default =
    { ... }:
    {
      imports = [
        fail2ban-rs
        fungi
        galgamemanager
        nextppp
        reader-server-rs
        selector4nix
        system76-scheduler-niri
      ];
    };
}
