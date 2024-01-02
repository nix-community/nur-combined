# clightning is an implementation of Bitcoin's Lightning Network.
# as such, this assumes that `services.bitcoin` is enabled.

{ config, ... }:
{
  sane.persist.sys.byStore.ext = [
    { user = "clightning"; group = "clightning"; path = "/var/lib/clightning"; }
  ];

  # see bitcoin.nix for how to generate this
  services.bitcoind.mainnet.rpc.users.clightning.passwordHMAC =
    "befcb82d9821049164db5217beb85439$2c31ac7db3124612e43893ae13b9527dbe464ab2d992e814602e7cb07dc28985";

  # sane.services.clightning.enable = true;
  sane.services.clightning.extraConfigFiles = config.sops.secrets."lightning-config";
  sops.secrets."lightning-config" = {
    mode = "0600";
    owner = "clightning";
    group = "clightning";
  };
  sane.services.clightning.proxy = "TODO";
}
