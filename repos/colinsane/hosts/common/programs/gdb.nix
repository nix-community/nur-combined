{ pkgs, ... }:
{
  sane.programs.gdb = {
    sandbox.enable = false;  # gdb doesn't sandbox well. i don't know how you could.
    sandbox.autodetectCliPaths = true;
    fs.".config/gdb/gdbinit".symlink.text = ''
      # enable commands like `py-bt`, `py-list`, etc.
      # for usage, see: <https://wiki.python.org/moin/DebuggingWithGdb>
      source ${pkgs.python3}/share/gdb/libpython.py
    '';
  };
}
