{ self }: {
  read-only-store = {
    proto = "virtiofs";
    tag = "ro-store";
    source = "/nix/store";
    mountPoint = "/nix/.ro-store";
    socket = "ro-store.socket";
  };

  tailscale-key = {
    proto = "virtiofs";
    tag = "tailscale";
    source = "/agenix/tailscale";
    mountPoint = "/agenix/tailscale";
    socket = "tailscale-identity-file.socket";
  };
}
