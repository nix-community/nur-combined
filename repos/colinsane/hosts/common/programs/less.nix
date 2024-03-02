{ ... }:
{
  sane.programs.less = {
    sandbox.method = "bwrap";
    sandbox.autodetectCliPaths = "existingFile";
    env.PAGER = "less";
  };
}
