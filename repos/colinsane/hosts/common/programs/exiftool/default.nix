{ ... }:
{
  sane.programs.exiftool = {
    # exiftool modifies files by writing out a new file adjacent to it and then `mv`ing it over the original file.
    # this requires it to have write access to the *parent* of whatever file it's operating on.
    sandbox.autodetectCliPaths = "parent";
    # sandbox.autodetectCliPaths = "existingFile";
  };
}
