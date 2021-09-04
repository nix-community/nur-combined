{
  display = ./display.nix;
  base16 = ./base16.nix;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      display
    ];
  };
}
