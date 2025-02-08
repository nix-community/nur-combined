# use like `haredoc bufio::read_line`
{ pkgs, ... }:
{
  sane.programs.haredoc = {
    sandbox.whitelistPwd = true;  #< search for function documentation below the current directory
    env.HAREPATH = builtins.toString pkgs.hare.src;
  };
}
