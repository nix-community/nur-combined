{ ... }:
{
  sane.programs.exiftool = {
    sandbox.method = "bwrap";
    sandbox.autodetectCliPaths = "existingFile";
  };
}
