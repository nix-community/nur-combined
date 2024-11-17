{ ... }:
{
  sane.programs.dasht = {
    suggestedPrograms = [ "docsets" ];
    fs.".local/share/dasht/docsets".symlink.target = "/run/current-system/sw/share/docsets";

    sandbox.method = null;  #< TODO: sandbox!
  };
}
