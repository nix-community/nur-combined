# as of 2023/12/02: complete blockchain is 530 GiB (on-disk size may be larger)
{ ... }:
{
  sane.persist.sys.byStore.ext = [
    # /var/lib/monero/lmdb is what consumes most of the space
    { user = "bitcoind-mainnet"; group = "bitcoind-mainnet"; path = "/var/lib/bitcoind-mainnet"; }
  ];

  sane.ports.ports."8333" = {
    # this allows other nodes and clients to download blocks from me.
    protocol = [ "tcp" ];
    visibleTo.wan = true;
    description = "colin-bitcoin";
  };

  services.bitcoind.mainnet = {
    enable = true;
    # TODO: set `rpc.users` to include my user
  };


}
