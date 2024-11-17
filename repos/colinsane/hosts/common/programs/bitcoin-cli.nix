{ pkgs, ... }:
{
  sane.programs.bitcoin-cli = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.bitcoind "bitcoin-cli";
    sandbox.autodetectCliPaths = "existing";  #< for `bitcoin-cli -datadir=/var/lib/...`
    sandbox.extraHomePaths = [
      ".bitcoin/bitcoin.conf"
    ];
    sandbox.net = "all";  # actually needs only localhost
    secrets.".bitcoin/bitcoin.conf" = ../../../secrets/servo/bitcoin.conf.bin;
  };
}
