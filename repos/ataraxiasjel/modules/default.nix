{
  authentik = ./authentik.nix;
  homepage = ./homepage.nix;
  hoyolab = ./hoyolab.nix;
  kes = ./kes.nix;
  ocis = ./ocis.nix;
  prometheus-exporters = import ./prometheus-exporters;
  rinetd = ./rinetd.nix;
  rustic = ./rustic.nix;
  syncyomi = ./syncyomi.nix;
  whoogle = ./whoogle.nix;
  wopiserver = ./wopiserver.nix;
}
