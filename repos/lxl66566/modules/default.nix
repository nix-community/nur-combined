{ ... }:
rec {
  fungi = ./fungi;
  nextppp = ./nextppp;
  selector4nix = ./selector4nix;
  system76-scheduler-niri = ./system76-scheduler-niri;

  default =
    { ... }:
    {
      imports = [
        fungi
        nextppp
        selector4nix
        system76-scheduler-niri
      ];
    };
}
