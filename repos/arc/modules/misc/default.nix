{
  display = ./display.nix;
  qemu = ./qemu.nix;
  base16 = ./base16.nix;
  connection = ./connection.nix;
  binding = ./binding.nix;
  ssl = ./ssl.nix;
  domain = ./domain.nix;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      display
      qemu
    ];
  };
}
