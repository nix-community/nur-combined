# `ausyscall --dump`: lists all syscalls by number and name
{ pkgs, ... }:
{
  sane.programs.ausyscall = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.audit "bin/ausyscall";

    sandbox.method = "landlock";
  };
}

