{
  display = ./display.nix;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      metamodes
    ];
  };
}
