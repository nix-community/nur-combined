{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.dots.apps.qutebrowser.enable = lib.mkEnableOption "Enable Qutebrowser config";
  config = lib.mkIf config.dots.apps.qutebrowser.enable {
    programs.qutebrowser = {
      enable = true;
      package = pkgs.qutebrowser.override { enableWideVine = pkgs.stdenv.hostPlatform.isx86_64; };
      settings = {
        colors.webpage = {
          darkmode.enabled = true;
          preferred_color_scheme = "dark";
        };
        content.blocking = {
          enabled = true;
          hosts.lists = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          ];
          method = "both";
        };
        url.default_page = "about:blank";
        url.start_pages = [ "about:blank" ];
      };
      extraConfig = ''
        config.bind("<Space>ff", "cmd-set-text -s :open")
        config.bind("<Space>fw", "cmd-set-text -s :open -t")
        config.bind("<Space>fb", "cmd-set-text -s :tab-focus")
        config.bind("<Space>fo", "history -t")
        config.bind("<Space><Return>", "bookmark-list --jump")
        config.bind("<Space>bc", "tab-clone")
        config.bind("<Space>bZ", "tab-only")
        config.bind("<Space>p", "tab-pin")
        config.bind("<Space>r", "reload")
        config.bind("<Space>yy", "yank")
        config.bind("<Space>yd", "yank domain")
        config.bind("<Space>ym", "yank inline [{title}]({url:yank})")
        config.bind("<Space>yn", "yank inline ({url:yank})[{title}]")
        config.bind("<Space>yt", "yank title")
        config.bind("<Ctrl-c>", "tab-close")
        config.bind("<Ctrl-C>", "tab-close -o")
        config.bind("<Space>i", "config-cycle content.images true false")
        config.bind("<Space>j", "config-cycle content.javascript.enabled true false")
        config.bind("<Ctrl-V>", "fake-key -g <Ctrl-v>")
        config.bind("<ctrl-alt-c>", "config-cycle tabs.show always never")

      '';
    };
  };
}
