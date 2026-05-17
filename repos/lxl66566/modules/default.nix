{ ... }:
rec {
  fungi = ./fungi;
  selector4nix = ./selector4nix;
  system76-scheduler-niri = ./system76-scheduler-niri;

  default =
    { ... }:
    {
      imports = [
        fungi
        selector4nix
        system76-scheduler-niri
      ];
    };
}
