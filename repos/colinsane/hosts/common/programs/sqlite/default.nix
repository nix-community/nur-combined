{ ... }:
{
  sane.programs.sqlite = {
    # for `sqlite3 /path/to/my.db`
    sandbox.autodetectCliPaths = "existingFile";
    # for `sqlite> .open my.db`
    sandbox.whitelistPwd = true;
  };
}
