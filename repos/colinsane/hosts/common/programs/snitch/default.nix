# snitch: a better lsof / ss
# - <https://github.com/karol-broda/snitch>
# config file:
# - ~/.config/snitch/snitch.toml
# - but it has excellent defaults
{ ... }:
{
  sane.programs.snitch = {
    sandbox.net = "all";
    sandbox.keepPidsAndProc = true;
    sandbox.tryKeepUsers = true;
    sandbox.capabilities = [
      "dac_read_search"
      "sys_ptrace"
    ];
  };
}
