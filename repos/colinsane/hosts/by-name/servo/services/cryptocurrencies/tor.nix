{ ... }:
{
  # tor: `tor.enable` doesn't start a relay, exit node, proxy, etc. it's minimal.
  # tor.client.enable configures a torsocks proxy, accessible *only* to localhost.
  #   at 127.0.0.1:9050
  services.tor.enable = true;
  services.tor.client.enable = true;
}
