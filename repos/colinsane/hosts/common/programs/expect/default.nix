{ pkgs, ... }:
{
  sane.programs.expect = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.expect "expect";
    sandbox.enable = false;  #< it's typically used to launch programs
  };
}
