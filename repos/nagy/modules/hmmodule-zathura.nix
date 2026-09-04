{
  imports = [ ./hmconvert.nix ];

  config.homeconfig.programs.zathura = {
    enable = true;
    options = {
      render-loading = false;
      dbus-raise-window = false;
      database = "null";
      selection-clipboard = "clipboard";
      first-page-column = "2";
      pages-per-row = 2;
      open-first-page = true;
      # naysayer color scheme (https://github.com/nickav/naysayer-theme.el):
      # dark green-blue chrome #062329, panel #0b3335, tan text #d1b897
      default-bg = "#062329";
      default-fg = "#d1b897";
      statusbar-bg = "#0b3335";
      statusbar-fg = "#d1b897";
      inputbar-bg = "#0b3335";
      inputbar-fg = "#d1b897";
      notification-bg = "#0b3335";
      notification-fg = "#d1b897";
      highlight-color = "#E6DB74";
      highlight-active-color = "#FD971F";
      # colors used when recolor is toggled (map t): dark pages, tan text
      recolor-lightcolor = "#062329";
      recolor-darkcolor = "#d1b897";
    };
    # for extraconfig:
    #    this is so you can open links in your browser. otherwise seccomp is active
    #    set sandbox none
    extraConfig = ''
      # map S feedkeys ":set first-page-column 1"<Return>
      # map D feedkeys ":set first-page-column 2"<Return>
      map S cycle_first_column
      map f toggle_page_mode
      map m toggle_statusbar
      map d scroll half-down
      map u scroll half-up
      map ^j scroll full-down
      map ^k scroll full-up
      map , scroll full-down
      map . scroll full-up
      map t recolor
      map Q quit
    '';
  };
}
