{
  nix = ./nix.nix;
  systemd = ./systemd.nix;
  systemd-user-translate = ./systemd-user-translate.nix;
  polkit-systemd = ./polkit-systemd.nix;
  users-chroot = ./users-chroot.nix;
  cpuinfo = ./cpuinfo.nix;
  dht22-exporter = ./dht22-exporter.nix;
  modprobe = ./modprobe.nix;
  kernel = ./kernel.nix;
  dsdt = ./dsdt.nix;
  crypttab = ./crypttab.nix;
  target = ./target.nix;
  glauth = ./glauth.nix;
  common-root = ./common-root.nix;
  mutable-state = ./mutable-state.nix;
  pulseaudio = ./pulseaudio.nix;
  wireplumber = ./wireplumber.nix;
  alsa = ./alsa.nix;
  yggdrasil = ./yggdrasil.nix;
  ddclient3 = ./ddclient.nix;
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
  home = ./home.nix;
  doc-warnings = ./doc-warnings.nix;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      nix
      systemd
      systemd-user-translate
      polkit-systemd
      users-chroot
      cpuinfo
      dht22-exporter
      target
      glauth
      modprobe
      kernel dsdt
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
      home
      doc-warnings
    ];
  };
}
