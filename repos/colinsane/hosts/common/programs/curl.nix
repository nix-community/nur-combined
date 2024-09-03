{ ... }:
{
  sane.programs.curl = {
    sandbox.method = "bunpen";
    sandbox.net = "all";
    sandbox.autodetectCliPaths = "parent";  #< for `-o` option
  };
}
