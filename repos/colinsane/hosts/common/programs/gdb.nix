{ pkgs, ... }:
{
  sane.programs.gdb = {
    sandbox.enable = false;  # gdb doesn't sandbox well. i don't know how you could.
    # sandbox.method = "landlock";  # permission denied when trying to attach, even as root
    sandbox.autodetectCliPaths = true;
    fs.".config/gdb/gdbinit".symlink.text = ''
      # enable commands like `py-bt`, `py-list`, etc.
      # for usage, see: <https://wiki.python.org/moin/DebuggingWithGdb>
      source ${pkgs.python3}/share/gdb/libpython.py
    '';
  };
}
