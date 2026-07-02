{ ... }:
{
  sane.programs.binwalk = {
    sandbox.whitelistPwd = true;  #< default extraction is to the current working directory... i think
    sandbox.autodetectCliPaths = "existing";  #< for -e
  };
}
