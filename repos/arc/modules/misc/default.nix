{
  display = ./display.nix;
  qemu = ./qemu.nix;
  base16 = ./base16.nix;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      display
      qemu
    ];
  };
}
