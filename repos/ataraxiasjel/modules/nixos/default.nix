{
  authentik = ./authentik.nix;
  endfield = ./endfield.nix;
  homepage = ./homepage.nix;
  hoyolab = ./hoyolab.nix;
  kes = ./kes.nix;
  mcp-gateway = ./mcp-gateway.nix;
  ocis = ./ocis.nix;
  opencodex = ./opencodex.nix;
  prometheus-exporters = import ./prometheus-exporters;
  rinetd = ./rinetd.nix;
  rustic = ./rustic.nix;
  syncyomi = ./syncyomi.nix;
  telemt = ./telemt.nix;
  whoogle = ./whoogle.nix;
  wopiserver = ./wopiserver.nix;
}
