# docs:
# - <https://www.gh-dash.dev/configuration/>
{ config, ... }:
{
  sane.programs.gh-dash = {
    # gh-dash calls into `gh ...` under the hood, or maybe just reuses the gh creds?
    suggestedPrograms = [ "gh" ];
    sandbox = config.sane.programs.gh.sandbox // {
      whitelistDbus.user.all = true;  #< because `gh` needs some dbus, and xdg-dbus-proxy doesn't support nesting
    };

    fs.".config/gh-dash/config.yml".symlink.target = ./config.yml;
  };
}
