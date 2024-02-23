# as of 2023/11/26: complete downloaded blockchain should be 200GiB on disk, give or take.
{ ... }:
{
  sane.persist.sys.byStore.ext = [
    # /var/lib/monero/lmdb is what consumes most of the space
    { user = "monero"; group = "monero"; path = "/var/lib/monero"; method = "bind"; }
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

  # monero ports: <https://monero.stackexchange.com/questions/604/what-ports-does-monero-use-rpc-p2p-etc>
  # - 18080 = "P2P" monero node <-> monero node connections
  # - 18081 = "RPC" monero client -> monero node connections
  sane.ports.ports."18080" = {
    protocol = [ "tcp" ];
    visibleTo.wan = true;
    description = "colin-monero-p2p";
  };
}
