{ ... }:
{
  sane.programs.curl = {
    sandbox.method = "bwrap";
    sandbox.net = "all";
    sandbox.autodetectCliPaths = "parent";  #< for `-o` option
  };
}
