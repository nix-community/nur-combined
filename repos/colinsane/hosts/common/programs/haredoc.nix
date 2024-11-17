# use like `haredoc bufio::read_line`
{ pkgs, ... }:
{
  sane.programs.haredoc = {
    sandbox.whitelistPwd = true;  #< search for function documentation below the current directory
    env.HAREPATH = "${pkgs.hare}/src/hare/stdlib";
  };
}
