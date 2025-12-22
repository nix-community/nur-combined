{ ... }:
rec {
  fungi = ./fungi;
  system76-scheduler-niri = ./system76-scheduler-niri;

  default =
    { ... }:
    {
      imports = [
        fungi
        system76-scheduler-niri
      ];
    };
}
