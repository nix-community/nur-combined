{ ... }:
rec {
  fail2ban-rs = ./fail2ban-rs;
  fungi = ./fungi;
  nextppp = ./nextppp;
  selector4nix = ./selector4nix;
  system76-scheduler-niri = ./system76-scheduler-niri;

  default =
    { ... }:
    {
      imports = [
        fail2ban-rs
        fungi
        nextppp
        selector4nix
        system76-scheduler-niri
      ];
    };
}
