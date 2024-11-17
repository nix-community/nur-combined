# clightning is an implementation of Bitcoin's Lightning Network.
# as such, this assumes that `services.bitcoin` is enabled.
# docs:
# - tor clightning config: <https://docs.corelightning.org/docs/tor>
# - `lightning-cli` and subcommands: <https://docs.corelightning.org/reference/lightning-cli>
# - `man lightningd-config`
#
# management/setup/use:
# - guide: <https://github.com/ElementsProject/lightning>
#
# debugging:
# - `lightning-cli getlog debug`
# - `lightning-cli listpays`  -> show payments this node sent
# - `lightning-cli listinvoices`  -> show payments this node received
#
# first, acquire peers:
# - `lightning-cli connect id@host`
#   where `id` is the node's pubkey, and `host` is perhaps an ip:port tuple, or a hash.onion:port tuple.
#   for testing, choose any node listed on <https://1ml.com>
# - `lightning-cli listpeers`
#   should show the new peer, with `connected: true`
#
# then, fund the clightning wallet
# - `lightning-cli newaddr`
#
# then, open channels
# - `lightning-cli connect ...`
# - `lightning-cli fundchannel <node_id> <amount_in_satoshis>`
#
# who to federate with?
# - a lot of the larger nodes allow hands-free channel creation
#   - either inbound or outbound, sometimes paid
# - find nodes on:
#   - <https://terminal.lightning.engineering/>
#   - <https://1ml.com>
#     - tor nodes: <https://1ml.com/node?order=capacity&iponionservice=true>
#   - <https://lightningnetwork.plus>
#   - <https://mempool.space/lightning>
#   - <https://amboss.space>
# - a few tor-capable nodes which allow channel creation:
#   - <https://c-otto.de/>
#   - <https://cyberdyne.sh/>
#   - <https://yalls.org/about/>
#   - <https://coincept.com/>
# - more resources: <https://www.lopp.net/lightning-information.html>
#   - node routability: https://hashxp.org/lightning/node/<id>
# - especially, acquire inbound liquidity via lightningnetwork.plus's swap feature
#   - most of the opportunities are gated behind a minimum connection or capacity requirement
#
# tune payment parameters
# - `lightning-cli setchannel <id> [feebase] [feeppm] [htlcmin] [htlcmax] [enforcedelay] [ignorefeelimits]`
#   - e.g. `lightning-cli setchannel all 0 10`
#   - it's suggested that feebase=0 simplifies routing.
#
# teardown:
# - `lightning-cli withdraw <bc1... dest addr> <amount in satoshis> [feerate]`
#
# sanity:
# - `lightning-cli listfunds`
#
# to receive a payment (do as `clightning` user):
# - `lightning-cli invoice <amount in millisatoshi> <label> <description>`
#   - specify amount as `any` if undetermined
#   - then give the resulting bolt11 URI to the payer
# to send a payment:
# - `lightning-cli pay <bolt11 URI>`
#   - or `lightning-cli pay <bolt11 URI> [amount_msat] [label] [riskfactor] [maxfeepercent] ...`
#   - amount_msat must be "null" if the bolt11 URI specifies a value
#   - riskfactor defaults to 10
#   - maxfeepercent defaults to 0.5
#   - label is a human-friendly label for my records

{ config, pkgs, ... }:
{
  sane.persist.sys.byStore.private = [
    # clightning takes up only a few MB. but then several hundred MB of crash logs that i should probably GC.
    { user = "clightning"; group = "clightning"; mode = "0710"; path = "/var/lib/clightning"; method = "bind"; }
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
  systemd.services.clightning.requires = [ "tor.service" ];

  # lightning-config contains fields from here:
  # - <https://docs.corelightning.org/docs/configuration>
  # secret config includes:
  # - bitcoin-rpcpassword
  # - alias=nodename
  # - rgb=rrggbb
  # - fee-base=<millisatoshi>
  # - fee-per-satoshi=<ppm>
  # - feature configs (i.e. experimental-xyz options)
  sane.services.clightning.extraConfig = ''
    # log levels: "io", "debug", "info", "unusual", "broken"
    log-level=info
    # log-level=info:lightningd
    # log-level=debug:lightningd
    # log-level=debug

    # peerswap:
    # - config example: <https://github.com/fort-nix/nix-bitcoin/pull/462/files#diff-b357d832705b8ce8df1f41934d613f79adb77c4cd5cd9e9eb12a163fca3e16c6>
    # XXX: peerswap crashes clightning on launch. stacktrace is useless.
    # plugin={lib.getExe' pkgs.peerswap "peerswap"}
    # peerswap-db-path=/var/lib/clightning/peerswap/swaps
    # peerswap-policy-path=...
  '';
  sane.services.clightning.extraConfigFiles = [ config.sops.secrets."lightning-config".path ];
  sops.secrets."lightning-config" = {
    mode = "0640";
    owner = "clightning";
    group = "clightning";
  };

  sane.programs.lightning-cli.enableFor.user.colin = true;  # for debugging/admin:
}
