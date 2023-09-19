{ mipmip_pkg, ... }:
{
  extpkg = mipmip_pkg.gnomeExtensions.gs-git;
  dconf = {
    name = "org/gnome/shell/extensions/gs-git";
    value = {
      alert-dirty-repos = true;
      disable-hiding = true;
      open-in-terminal-command = "st -d '%WORKING_DIRECTORY' -- bash -c 'git status; bash'";
      show-changed-files = false;
    };
  };
}



