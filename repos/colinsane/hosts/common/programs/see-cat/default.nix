{ ... }:
{
  sane.programs.see-cat = {
    # if image rendering is enabled, "existing" may be too restrictive;
    # grant access to the whole directory, as images are usually somewhere within that.
    sandbox.autodetectCliPaths = "existingDirOrParent";
  };
}
