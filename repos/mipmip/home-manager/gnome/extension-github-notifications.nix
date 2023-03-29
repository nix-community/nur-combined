{ mipmip_pkg, ... }:
{
  extpkg = mipmip_pkg.gnomeExtensions.github-notifications;
  dconf = {
    name = "org/gnome/shell/extensions/github-notifications";
    value = {
      hide-notification-count = false;
      hide-widget = false;
      show-alert = false;
      show-participating-only = false;
      token = "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";
    };
  };
}

