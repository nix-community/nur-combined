# `ausyscall --dump`: lists all syscalls by number and name
{ pkgs, ... }:
{
  sane.programs.ausyscall = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.audit "ausyscall";
  };
}
