{ ... }:
{
  sane.programs."unixtools.xxd" = {
    sandbox.autodetectCliPaths = "existingFile";
  };
}
