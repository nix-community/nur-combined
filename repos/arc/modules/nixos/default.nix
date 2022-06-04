{
  nix = ./nix.nix;
  systemd = ./systemd.nix;
  dht22-exporter = ./dht22-exporter.nix;
  modprobe = ./modprobe.nix;
  kernel = ./kernel.nix;
  crypttab = ./crypttab.nix;
  glauth = ./glauth.nix;
  common-root = ./common-root.nix;
  mutable-state = ./mutable-state.nix;
  pulseaudio = ./pulseaudio.nix;
  wireplumber = ./wireplumber.nix;
  alsa = ./alsa.nix;
  yggdrasil = ./yggdrasil.nix;
  bindings = import ./bindings.nix // {
    __functor = _: { ... }: { imports = [ ./bindings.nix ]; };
  };
  service-bindings = import ./service-bindings.nix // {
    __functor = _: { ... }: { imports = [ ./service-bindings.nix ]; };
  };
  matrix-appservices = ./matrix-appservices.nix;
  matrix-synapse-appservices = ./matrix-synapse-appservices.nix;
  display = ./display.nix;
  filebin = ./filebin.nix;
  mosh = ./mosh.nix;
  base16 = ./base16.nix;
  base16-shared = import ../home/base16.nix true;
  doc-warnings = ./doc-warnings.nix;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      nix
      systemd
      dht22-exporter
      glauth
      modprobe
      kernel
      crypttab
      mutable-state
      common-root
      pulseaudio
      wireplumber
      alsa
      yggdrasil
      bindings
      service-bindings
      matrix-appservices
      matrix-synapse-appservices
      display
      filebin
      mosh
      base16 base16-shared
      doc-warnings
    ];
  };
}
