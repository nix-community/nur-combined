{
  yggdrasil = ./yggdrasil.nix;
  keychain = import ./keychain.nix true;
  filebin = ./filebin.nix;
  mosh = ./mosh.nix;
  base16 = ./base16.nix;
  base16-shared = import ../home/base16.nix true;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      yggdrasil
      keychain
      filebin
      mosh
      base16 base16-shared
    ];
  };
}
