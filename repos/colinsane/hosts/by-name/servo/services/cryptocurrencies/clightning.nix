# clightning is an implementation of Bitcoin's Lightning Network.
# as such, this assumes that `services.bitcoin` is enabled.
# docs:
# - tor clightning config: <https://docs.corelightning.org/docs/tor>
#
# management/setup/use:
# - guide: <https://github.com/ElementsProject/lightning>
# - `sudo -u clightning -g clightning lightning-cli help`
#
# first, acquire peers:
# - `lightning-cli listpeers`
#
# sanity:
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
  sane.services.clightning.proxy = "127.0.0.1:9050";  # proxy outgoing traffic through tor
  # sane.services.clightning.publicAddress = "statictor:127.0.0.1:9051";
  sane.services.clightning.getPublicAddressCmd = "cat /var/lib/tor/onion/clightning/hostname";

  services.tor.relay.onionServices.clightning = {
    version = 3;
    map = [{
      # by default tor will route public tor port P to 127.0.0.1:P.
      # so if this port is the same as clightning would natively use, then no further config is needed here.
      # see: <https://2019.www.torproject.org/docs/tor-manual.html.en#HiddenServicePort>
      port = 9735;
      # target.port; target.addr;  #< set if tor port != clightning port
    }];
    # allow "tor" group (i.e. clightning) to read /var/lib/tor/onion/clightning/hostname
    settings.HiddenServiceDirGroupReadable = true;
  };

  # must be in "tor" group to read /var/lib/tor/onion/*/hostname
  users.users.clightning.extraGroups = [ "tor" ];

  systemd.services.clightning.after = [ "tor.service" ];

  sane.services.clightning.extraConfigFiles = [ config.sops.secrets."lightning-config".path ];
  sops.secrets."lightning-config" = {
    mode = "0600";
    owner = "clightning";
    group = "clightning";
  };

  sane.programs.clightning.enableFor.user.colin = true;  # put `lightning-cli` onto PATH
}
