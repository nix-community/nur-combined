# clightning is an implementation of Bitcoin's Lightning Network.
# as such, this assumes that `services.bitcoin` is enabled.
#
# management/setup/use:
# - guide: <https://github.com/ElementsProject/lightning>
# - `sudo -u clightning -g clightning lightning-cli help`
# - `lightning-cli listfunds`
#
# to receive a payment (do as `clightning` user):
# - `lightning-cli invoice <amount in millisatoshi> <label> <description>`
#   - then give the resulting bolt11 URI to the payer
# to send a payment:
# - `lightning-cli pay <bolt11 URI>`

{ config, ... }:
{
  sane.persist.sys.byStore.ext = [
    { user = "clightning"; group = "clightning"; mode = "0700"; path = "/var/lib/clightning"; }
  ];

  # see bitcoin.nix for how to generate this
  services.bitcoind.mainnet.rpc.users.clightning.passwordHMAC =
    "befcb82d9821049164db5217beb85439$2c31ac7db3124612e43893ae13b9527dbe464ab2d992e814602e7cb07dc28985";

  sane.services.clightning.enable = true;
  sane.services.clightning.extraConfigFiles = [ config.sops.secrets."lightning-config".path ];
  sops.secrets."lightning-config" = {
    mode = "0600";
    owner = "clightning";
    group = "clightning";
  };
  sane.services.clightning.proxy = "127.0.0.1:9050";  # tor

  sane.programs.clightning.enableFor.user.colin = true;  # put `lightning-cli` onto PATH
}
