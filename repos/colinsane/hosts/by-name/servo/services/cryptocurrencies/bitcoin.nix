# as of 2023/12/02: complete blockchain is 530 GiB (on-disk size may be larger)
#
# rpc setup:
# - generate a password
#   - use: <https://github.com/bitcoin/bitcoin/blob/master/share/rpcauth/rpcauth.py>
#     (rpcauth.py is not included in the `'.#bitcoin'` package result)
#   - `wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py`
#   - `python ./rpcauth.py colin`
#   - copy the hash here. it's SHA-256, so safe to be public.
#   - add "rpcuser=colin" and "rpcpassword=<output>" to secrets/servo/bitcoin.conf  (i.e. ~/.bitcoin/bitcoin.conf)
#     - bitcoin.conf docs: <https://github.com/bitcoin/bitcoin/blob/master/doc/bitcoin-conf.md>
# - validate with `bitcoin-cli -netinfo`
{ config, sane-lib, ... }:
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
    rpc.users.colin = {
      # see docs at top of file for how to generate this
      passwordHMAC = "30002c05d82daa210550e17a182db3f3$6071444151281e1aa8a2729f75e3e2d224e9d7cac3974810dab60e7c28ffaae4";
    };
    extraConfig = ''
      # don't load the wallet, and disable wallet RPC calls
      disablewallet=1
      # TODO: configure tor integration
      # proxy=127.0.0.1:9050
      # externalip=$(cat /var/lib/tor/onion/bitcoind/hostname)
    '';
  };

  sane.users.colin.fs.".bitcoin/bitcoin.conf" = sane-lib.fs.wantedSymlinkTo config.sops.secrets."bitcoin.conf".path;
  sops.secrets."bitcoin.conf" = {
    mode = "0600";
    owner = "colin";
    group = "users";
  };
}
