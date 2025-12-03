{ pkgs, ... }:
{
  sane.programs.socat = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.socat [
      "socat"
      # socat-broker.sh, socat-chain.sh, socat-mux.sh
      "socat-*"
    ];
    sandbox.net = "all";
  };
}
