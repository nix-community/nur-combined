{ ... }:
{
  sane.programs.curl = {
    sandbox.net = "all";
    sandbox.autodetectCliPaths = "parent";  #< for `-o` option
  };
}
