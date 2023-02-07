{
  proto = "virtiofs";
  tag = "ro-store";
  source = "/nix/store";
  mountPoint = "/nix/.ro-store";
  socket = "ro-store.socket";
}
