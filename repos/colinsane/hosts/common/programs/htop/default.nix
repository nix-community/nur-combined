{ ... }:
{
  sane.programs.htop = {
    sandbox.method = "landlock";
    sandbox.extraPaths = [
      "/proc"
      "/sys/devices"
    ];
    fs.".config/htop/htoprc".symlink.target = ./htoprc;
  };
}
