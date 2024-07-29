{ pkgs, ... }:
{
  sane.programs.bitcoin-cli = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.bitcoind "bin/bitcoin-cli";
    sandbox.method = "bwrap";
    sandbox.autodetectCliPaths = "existing";  #< for `bitcoin-cli -datadir=/var/lib/...`
    sandbox.extraHomePaths = [
      ".bitcoin/bitcoin.conf"
    ];
    sandbox.net = "all";  # actually needs only localhost
    secrets.".bitcoin/bitcoin.conf" = ../../../secrets/servo/bitcoin.conf.bin;
  };
}
