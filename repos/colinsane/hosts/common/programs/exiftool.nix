{ ... }:
{
  sane.programs.exiftool = {
    sandbox.method = "bunpen";
    sandbox.autodetectCliPaths = "existingFile";
  };
}
