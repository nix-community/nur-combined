# as of 2023/11/26: complete downloaded blockchain should be 200GiB on disk, give or take.
{ ... }:
{
  sane.persist.sys.byStore.ext = [
    # /var/lib/monero/lmdb is what consumes most of the space
    { user = "monero"; group = "monero"; path = "/var/lib/monero"; }
  ];

  services.monero.enable = true;
  services.monero.limits.upload = 5000;  # in kB/s
  services.monero.extraConfig = ''
    # see: monero doc/ANONYMITY_NETWORKS.md
    #
    # "If any anonymity network is enabled, transactions being broadcast that lack a valid 'context'
    # (i.e. the transaction did not come from a P2P connection) will only be sent to peers on anonymity networks."
    #
    # i think this means that setting tx-proxy here ensures any transactions sent locally to my node (via RPC)
    # will be sent over an anonymity network.
    tx-proxy=i2p,127.0.0.1:9000
    tx-proxy=tor,127.0.0.1:9050
  '';

  services.i2p.enable = true;
  # tor: `tor.enable` doesn't start a relay, exit node, proxy, etc. it's minimal.
  # tor.client.enable configures a torsocks proxy, accessible *only* to localhost.
  services.tor.enable = true;
  services.tor.client.enable = true;
}
