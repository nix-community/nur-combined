{
  modprobe = ./modprobe.nix;
  pulseaudio = ./pulseaudio.nix;
  pipewire = ./pipewire.nix;
  yggdrasil = ./yggdrasil.nix;
  display = ./display.nix;
  filebin = ./filebin.nix;
  mosh = ./mosh.nix;
  base16 = ./base16.nix;
  base16-shared = import ../home/base16.nix true;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      modprobe
      pulseaudio
      pipewire
      yggdrasil
      display
      filebin
      mosh
      base16 base16-shared
    ];
  };
}
