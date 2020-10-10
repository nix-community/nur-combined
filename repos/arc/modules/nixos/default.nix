{
  yggdrasil = ./yggdrasil.nix;
  filebin = ./filebin.nix;
  mosh = ./mosh.nix;
  base16 = ./base16.nix;
  base16-shared = import ../home/base16.nix true;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      yggdrasil
      filebin
      mosh
      base16 base16-shared
    ];
  };
}
