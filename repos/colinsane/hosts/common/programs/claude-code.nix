{ ... }:
{
  sane.programs.claude-code = {
    sandbox.net = "clearnet";
    sandbox.whitelistPortal = [
      "OpenURI"  #< for initial browser-based auth
    ];
    sandbox.whitelistPwd = true;

    # $100B company SELLING TO DEVS can't even figure out how to follow XDG specs, what a glorious future.
    fs.".claude".symlink.target = ".local/share/claude";
    fs.".claude.json".symlink.target = ".config/claude/claude.json";  #< API keys, granted perms

    persist.byStore.private = [
      ".config/claude"
      ".local/share/claude"
    ];
  };
}
