{
  config,
  pkgs,
  ...
}:

{
  imports = [ ./hmconvert.nix ];

  config.homeconfig.programs.zathura = {
    enable = config.services.xserver.enable;
    # package = (pkgs.zathuraPkgs.override { useMupdf = false; }).zathuraWrapper;
    package = pkgs.zathura.override {
      zathura_core = pkgs.zathuraPkgs.zathura_core.overrideAttrs {
        # Use 0.5.11 because 0.5.13 has a bug that when opening a
        # file, the view mode is broken
        src = pkgs.fetchurl {
          url = "https://pwmt.org/projects/zathura/download/zathura-0.5.11.tar.xz";
          hash = "sha256-VEWKmZivD7j67y6TSoESe75LeQyG3NLIuPMjZfPRtTw=";
        };
      };
    };
    options = {
      render-loading = false;
      dbus-raise-window = false;
      database = "null";
      # first-page-column = "1:2";
      selection-clipboard = "clipboard";
      # pages-per-row = 2;
      open-first-page = true;
      # recolor-reverse-video = true; # this prevents image pdfs from being recolored
      # sandbox = "strict";
      # double-click-follow = true # already the default
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
