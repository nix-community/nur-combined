{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = builtins.mapAttrs (k: v: "#${v}") pkgs.custom.colors.colors;
  stylesheetBase16Variables = pkgs.writeText "base16.css" ''
    :root {
      ${
        builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (k: v: "--${k}: ${v};") c))
      }
    }
  '';
in
{
  config = lib.mkIf config.programs.qutebrowser.enable {
    programs.qutebrowser = {
      keyBindings = {
        normal = {
          xb = "config-cycle statusbar.show always never";
          xt = "config-cycle tabs.show always never";
          xx = "config-cycle statusbar.show always never;; config-cycle tabs.show always never";
        };
      };
      greasemonkey = [

      ];
      quickmarks = {
        nixpkgs = "https://github.com/NixOS/nixpkgs";
        hm-options = "https://nix-community.github.io/home-manager/options.html";
        nixos-options = "https://search.nixos.org/options";
        miniflux = "http://miniflux.whiterun.lucao.net";
        yt = "http://invidious.whiterun.lucao.net";
        whiterun = "http://whiterun.lucao.net";
        nc = "http://nextcloud.whiterun.lucao.net/apps/files/";
        grafana = "http://grafana.whiterun.lucao.net/dashboards";
      };
      searchEngines = {
        a = "https://articleparser.vercel.app/api?url={}";
        w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
        aw = "https://wiki.archlinux.org/?search={}";
        nw = "https://nixos.wiki/index.php?search={}";
        g = "https://www.google.com/search?hl=en&q={}";
        ddg = "https://duckduckgo.com/?t=h_&q={}";
        nixpkgs = "https://github.com/search?q=repo%3ANixOS%2Fnixpkgs%20{}";
        options = "https://search.nixos.org/options?query={}";
        yt = "http://invidious.whiterun.lucao.net/search?q={}";
        so = "https://stackoverflow.com/search?q={}";
        cft = "http://cf-torrent.whiterun.lucao.net/search/torrent/result?use_google=1&use_duckduckgo=1&query={}";
        ml = "https://lista.mercadolivre.com.br/{}";
      };
      settings = {
        content = {
          user_stylesheets = map (item: "${item}") [ stylesheetBase16Variables ];
        };
        colors = {

          completion = {

            fg = c.base05;

            # Background color of the completion widget for odd rows.
            odd.bg = c.base01;

            # Background color of the completion widget for even rows.
            even.bg = c.base00;
            category = {

              # Foreground color of completion widget category headers.
              fg = c.base0A;

              # Background color of the completion widget category headers.
              bg = c.base00;
              border = {

                # Top border color of the completion widget category headers.
                top = c.base00;

                # Bottom border color of the completion widget category headers.
                bottom = c.base00;
              };
            };
            item = {
              selected = {

                # Foreground color of the selected completion item.
                fg = c.base05;

                # Background color of the selected completion item.
                bg = c.base02;

                # Top border color of the selected completion item.
                border.top = c.base02;

                # Bottom border color of the selected completion item.
                border.bottom = c.base02;

                # Foreground color of the matched text in the selected completion item.
                match.fg = c.base0B;
              };
            };

            # Foreground color of the matched text in the completion.
            match.fg = c.base0B;
            scrollbar = {

              # Color of the scrollbar handle in the completion view.
              fg = c.base05;

              # Color of the scrollbar in the completion view.
              bg = c.base00;
            };
          };
          contextmenu = {

            # Background color of disabled items in the context menu.
            disabled.bg = c.base01;

            # Foreground color of disabled items in the context menu.
            disabled.fg = c.base04;

            # Background color of the context menu. If set to null, the Qt default is used.
            menu.bg = c.base00;

            # Foreground color of the context menu. If set to null, the Qt default is used.
            menu.fg = c.base05;

            # Background color of the context menu’s selected item. If set to null, the Qt default is used.
            selected.bg = c.base02;

            #Foreground color of the context menu’s selected item. If set to null, the Qt default is used.
            selected.fg = c.base05;
          };
          downloads = {

            # Background color for the download bar.
            bar.bg = c.base00;

            # Color gradient start for download text.
            start.fg = c.base00;

            # Color gradient start for download backgrounds.
            start.bg = c.base0D;

            # Color gradient end for download text.
            stop.fg = c.base00;

            # Color gradient stop for download backgrounds.
            stop.bg = c.base0C;

            # Foreground color for downloads with errors.
            error.fg = c.base08;
          };
          hints = {

            # Font color for hints.
            fg = c.base00;

            # Background color for hints. Note that you can use a `rgba(...)` value
            # for transparency.
            bg = c.base0A;

            # Font color for the matched part of hints.
            match.fg = c.base05;
          };
          keyhint = {

            # Text color for the keyhint widget.
            fg = c.base05;

            # Highlight color for keys to complete the current keychain.
            suffix.fg = c.base05;

            # Background color of the keyhint widget.
            bg = c.base00;
          };
          messages = {
            error = {

              # Foreground color of an error message.
              fg = c.base00;

              # Background color of an error message.
              bg = c.base08;

              # Border color of an error message.
              border = c.base08;
            };
            warning = {

              # Foreground color of a warning message.
              fg = c.base00;

              # Background color of a warning message.
              bg = c.base0E;

              # Border color of a warning message.
              border = c.base0E;
            };
            info = {

              # Foreground color of an info message.
              fg = c.base05;

              # Background color of an info message.
              bg = c.base00;

              # Border color of an info message.
              border = c.base00;
            };
          };
          prompts = {

            # Foreground color for prompts.
            fg = c.base05;

            # Border used around UI elements in prompts.
            border = c.base00;

            # Background color for prompts.
            bg = c.base00;
            selected = {

              # Background color for the selected item in filename prompts.
              bg = c.base02;

              # Foreground color for the selected item in filename prompts.
              fg = c.base05;
            };
          };
          statusbar = {
            normal = {

              # Foreground color of the statusbar.
              fg = c.base0B;

              # Background color of the statusbar.
              bg = c.base00;
            };
            insert = {

              # Foreground color of the statusbar in insert mode.
              fg = c.base00;

              # Background color of the statusbar in insert mode.
              bg = c.base0D;
            };
            passthrough = {

              # Foreground color of the statusbar in passthrough mode.
              fg = c.base00;

              # Background color of the statusbar in passthrough mode.
              bg = c.base0C;
            };
            private = {

              # Foreground color of the statusbar in private browsing mode.
              fg = c.base00;

              # Background color of the statusbar in private browsing mode.
              bg = c.base01;
            };
            command = {

              # Foreground color of the statusbar in command mode.
              fg = c.base05;

              # Background color of the statusbar in command mode.
              bg = c.base00;

              # Foreground color of the statusbar in private browsing + command mode.
              private.fg = c.base05;

              # Background color of the statusbar in private browsing + command mode.
              private.bg = c.base00;
            };
            caret = {

              # Foreground color of the statusbar in caret mode.
              fg = c.base00;

              # Background color of the statusbar in caret mode.
              bg = c.base0E;

              # Foreground color of the statusbar in caret mode with a selection.
              selection.fg = c.base00;

              # Background color of the statusbar in caret mode with a selection.
              selection.bg = c.base0D;
            };

            # Background color of the progress bar.
            progress.bg = c.base0D;
            url = {

              # Default foreground color of the URL in the statusbar.
              fg = c.base05;

              # Foreground color of the URL in the statusbar on error.
              error.fg = c.base08;

              # Foreground color of the URL in the statusbar for hovered links.
              hover.fg = c.base05;

              # Foreground color of the URL in the statusbar on successful load
              # (http).
              success.http.fg = c.base0C;

              # Foreground color of the URL in the statusbar on successful load
              # (https).
              success.https.fg = c.base0B;

              # Foreground color of the URL in the statusbar when there's a warning.
              warn.fg = c.base0E;
            };
          };
          tabs = {

            # Background color of the tab bar.
            bar.bg = c.base00;

            # Color gradient start for the tab indicator.
            indicator.start = c.base0D;

            # Color gradient end for the tab indicator.
            indicator.stop = c.base0C;

            # Color for the tab indicator on errors.
            indicator.error = c.base08;

            # Foreground color of unselected odd tabs.
            odd.fg = c.base05;

            # Background color of unselected odd tabs.
            odd.bg = c.base01;

            # Foreground color of unselected even tabs.
            even.fg = c.base05;

            # Background color of unselected even tabs.
            even.bg = c.base00;
            pinned = {

              # Background color of pinned unselected even tabs.
              even.bg = c.base0C;

              # Foreground color of pinned unselected even tabs.
              even.fg = c.base07;

              # Background color of pinned unselected odd tabs.
              odd.bg = c.base0B;

              # Foreground color of pinned unselected odd tabs.
              odd.fg = c.base07;
              selected = {

                # Background color of pinned selected even tabs.
                even.bg = c.base02;

                # Foreground color of pinned selected even tabs.
                even.fg = c.base05;

                # Background color of pinned selected odd tabs.
                odd.bg = c.base02;

                # Foreground color of pinned selected odd tabs.
                odd.fg = c.base05;
              };
            };
            selected = {

              # Foreground color of selected odd tabs.
              odd.fg = c.base05;

              # Background color of selected odd tabs.
              odd.bg = c.base02;

              # Foreground color of selected even tabs.
              even.fg = c.base05;

              # Background color of selected even tabs.
              even.bg = c.base02;
            };
          };
          webpage = {

            # Background color for webpages if unset (or empty to use the theme's
            # color).
            # bg = c.base00;
            darkmode.enabled = true;
          };
        };
        # colors.webpage.darkmode.policy.images = "never";
      };
    };
  };
}
