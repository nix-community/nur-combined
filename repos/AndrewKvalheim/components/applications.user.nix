{ config, lib, pkgs, ... }:

let
  inherit (builtins) listToAttrs;
  inherit (config) system;
  inherit (config.programs) kitty;
  inherit (lib) foldlAttrs getExe getExe' imap0 mkOption nameValuePair throwIfNot;
  inherit (lib.generators) toINI toKeyValue toYAML;
  inherit (lib.hm.gvariant) mkTuple mkUint32;
  inherit (pkgs) formats makeAutostartItem onlyBin;
  inherit (pkgs.writers) writeTOML;

  palette = import ../library/palette.lib.nix { inherit lib pkgs; };
in
{
  imports = [
    ../library/nautilus-scripts.user.nix
    ../library/organize-downloads.user.nix
  ];

  options = {
    programs.gopass.settings = mkOption { type = (formats.ini { }).type; default = { }; };
  };

  config = {
    # Unfree packages
    nixpkgs.config.allowUnfreePackages = [
      "ffmpeg"
      "vagrant"
    ];

    # Associations
    xdg.mimeApps = {
      enable = true;
      defaultApplications = foldlAttrs (byType: handler: types: byType // (listToAttrs (map (type: nameValuePair type handler) types))) { } {
        "codium.desktop" = [ "application/gpx+xml" "application/json" "application/rss+xml" "application/x-shellscript" "application/xml" "message/rfc822" "text/markdown" "text/plain" ];
        "firefox.desktop" = [ "application/xhtml+xml" "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
        "fstlapp-fstl.desktop" = [ "model/stl" ];
        "org.gnome.Loupe.desktop" = [ "image/heif" ];
        "org.gnome.Papers.desktop" = [ "image/x-eps" ];
        "studio.planetpeanut.Bobby.desktop" = [ "application/vnd.sqlite3" ];
        "writer.desktop" = [ "application/vnd.oasis.opendocument.text" "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ];
      };
    };
    xdg.configFile."mimeapps.list".force = true; # Workaround for nix-community/home-manager#1213

    # Modules
    programs.fastfetch.enable = true;
    programs.fd.enable = true;
    programs.gopass.settings = {
      core.autosync = false;
      edit.auto-create = true;
    };
    programs.joplin-desktop = {
      enable = true;
      extraConfig = {
        "locale" = "en_US";
        "dateFormat" = "YYYY-MM-DD";
        "timeFormat" = "HH:mm";
        "export.pdfPageSize" = "Letter";
        "showTrayIcon" = true;
        "style.editor.fontFamily" = "Iosevka Custom Proportional";
        "style.editor.monospaceFontFamily" = "Iosevka Custom Mono";
        "editor.spellcheckBeta" = true; # laurent22/joplin#6453
      };
    };
    programs.jq.enable = true;
    programs.numbat = {
      enable = true;
      settings = {
        exchange-rates.fetching-policy = "on-first-use";
        intro-banner = "off";
        prompt = "❯ ";
      };
    };
    programs.ripgrep.enable = true;
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false; # Deprecated
      includes = [ "config.d/*" ];
      extraOptionOverrides.PreferredAuthentications = "publickey";
    };
    programs.visidata = {
      enable = true;
      visidatarc = with pkgs; toKeyValue { } {
        "options.clipboard_copy_cmd" = getExe' wl-clipboard "wl-copy";
        "options.clipboard_paste_cmd" = "${getExe' wl-clipboard "wl-paste"} --no-newline";
      };
    };

    # Packages
    home.packages = with pkgs; [
      add-words
      bacon
      binsider
      bobby
      bubblewrap # Required by nixpkgs-review --sandbox
      bustle
      cavif
      cargo-msrv
      constrict
      darktable
      dconf-editor
      deskflow
      dig
      displaycal
      dive
      dua
      duperemove
      efficient-compression-tool
      (makeAutostartItem { name = "com.tomjwatson.Emote"; package = emote; })
      exiftool
      eyedropper
      (ffmpeg.override { withUnfree = true; withFdkAac = true; })
      file
      fstl
      fq
      gifsicle
      gimp3-with-plugins
      gnome-decoder
      gopass
      gopass-env
      gopass-ydotool
      gradia
      gucharmap
      guetzli
      guvcview
      hdparm
      htop
      hurl
      hydra-check
      identity
      ijq
      imagemagickBig
      img2pdf
      (inkscape-with-extensions.override { inkscapeExtensions = with inkscape-extensions; [ applytransforms ]; })
      ipcalc
      iperf
      isd
      jless
      just
      just-local
      killall
      (onlyBin libwebp) # cwebp
      lsof
      magic-wormhole
      miller
      moreutils
      mozjpeg-simple
      mtr
      multitail
      netdiscover
      nix-output-monitor
      nix-preview
      nix-top
      nix-tree
      nixpkgs-hammering
      nixpkgs-review
      nom-wrappers
      off
      oha
      kdePackages.okular
      oxvg
      patchutils
      pdfarranger
      pdfcpu
      popsicle
      pngquant
      pngtools
      poppler-utils # pdfinfo
      pup
      pwgen
      pwvucontrol
      rsync
      s-tui
      snitch
      smartmontools
      sort-domains
      sqlitebrowser
      step-cli
      svgo
      texlive.pkgs.albatross
      trash-cli
      uniscribe
      unln
      usbutils
      v4l-utils
      vagrant
      vivictpp
      warp
      watchlog
      wev
      whois
      wireguard-tools
      wl-clipboard
      xan
      xev
      xh
      xkcdpass
      yq
    ];

    # Nautilus scripts
    nautilusScripts = with pkgs; {
      "HEIF,PNG,TIFF → JPEG".xargs = "-n 1 -P 8 nice ${getExe mozjpeg-simple}";
      "JPEG: Strip geolocation".xargs = "nice ${getExe exiftool} -overwrite_original -gps:all= -xmp:geotag=";
      "PNG: Optimize".xargs = ''
        nice ${getExe efficient-compression-tool} -8 -keep -quiet --mt-file \
        2> >(${getExe zenity} --width 600 --progress --pulsate --auto-close --auto-kill)
      '';
      "PNG: Quantize".each = ''
        ${getExe pngquant-interactive} --suffix '.qnt' "$path"
        nice ${getExe efficient-compression-tool} -8 -keep -quiet "''${path%.png}.qnt.png"
      '';
      "PNG: Trim".xargs = "-n 1 -P 8 nice ${getExe' imagemagick "mogrify"} -trim";
    };

    # GNOME Shell launcher scripts
    launcherScripts = with pkgs; {
      "issue reference → GitHub URL" = ''
        if result="$(
          ${getExe' wl-clipboard "wl-paste"} --no-newline --type 'text' \
          | sed --regexp-extended --quiet '\@^(.+)#(.+)$@{s@@https://github.com/\1/issues/\2@p;q};q1'
        )"; then
          ${getExe' wl-clipboard "wl-copy"} --type 'TEXT' "$result"
          ${getExe' libnotify "notify-send"} --icon 'edit-copy-symbolic' --transient 'Updated clipboard' "$result"
        else
          ${getExe' libnotify "notify-send"} --icon 'dialog-error-symbolic' --transient 'Failed to updated clipboard' 'Not an issue reference'
        fi
      '';
      "issue URL → markdown link" = ''
        if result="$(
          ${getExe' wl-clipboard "wl-paste"} --no-newline --type 'text' \
          | sed --regexp-extended --quiet '\@^(https://[^/]+/([^/]+/[^/]+)/(issues|pull)/([[:digit:]]+))$@{s//[\2#\4](\1)/p;q};q1'
        )"; then
          ${getExe' wl-clipboard "wl-copy"} --type 'TEXT' "$result"
          ${getExe' libnotify "notify-send"} --icon 'edit-copy-symbolic' --transient 'Updated clipboard' "$result"
        else
          ${getExe' libnotify "notify-send"} --icon 'dialog-error-symbolic' --transient 'Failed to updated clipboard' 'Not an issue URL'
        fi
      '';
    };

    # Configuration
    home.sessionVariables = {
      ADD_WORDS_WORDLIST_PATH = ./assets/words.txt;
      ANSIBLE_NOCOWS = "🐄"; # Workaround for ansible/ansible#10530
      PYTHON_KEYRING_BACKEND = "keyring.backends.fail.Keyring"; # Workaround for python-poetry/poetry#8761
      UV_PYTHON_DOWNLOADS = "never";
    };
    xdg.configFile."cargo-release/release.toml".source = writeTOML "release.toml" {
      push = false;
      publish = false;
      pre-release-commit-message = "Version {{version}}";
      tag-message = "Version {{version}}";
    };
    xdg.configFile."isd_tui/config.yaml".text = toYAML { } {
      main_keybindings = {
        toggle_mode = throwIfNot (kitty.keybindings ? "ctrl+t") "No conflict" "ctrl+m";
      };
    };
    home.file.".npmrc".text = toKeyValue { } {
      fund = false;
      ignore-scripts = true;
      sign-git-tag = true;
      update-notifier = false;
    };
    xdg.configFile."rustfmt/rustfmt.toml".source = writeTOML "rustfmt.toml" {
      condense_wildcard_suffixes = true;
      # error_on_unformatted = true; # Pending rust-lang/rustfmt#3392
      use_field_init_shorthand = true;
      use_try_shorthand = true;
    };
    home.file.".shellcheckrc".text = "disable=SC1111";
    home.file.".ssh/config.d/.keep".text = "";
    dconf.settings."org/gnome/gnome-system-monitor" = with palette.hex; {
      cpu-colors = imap0 (i: c: mkTuple [ (mkUint32 i) c ]) (
        {
          "4" = [ red orange green blue ];
          "6" = [ red orange yellow green blue purple ];
          "8" = [ red vermilion orange yellow green teal blue purple ];
          "12" = [ red red-dim orange orange-dim yellow yellow-dim green green-dim blue blue-dim purple purple-dim ];
          "16" = [ red red-dim vermilion vermilion-dim orange orange-dim yellow yellow-dim green green-dim teal teal-dim blue blue-dim purple purple-dim ];
        }."${toString system.host.metrics.cpuCores}"
      );
      mem-color = orange;
      swap-color = purple;
      net-in-color = blue;
      net-out-color = red;
    };
    home.file.".vagrant.d/Vagrantfile".text =
      let ip = "192.168.56.1" /* networking.interfaces.vboxnet0 */; in ''
        Vagrant.configure('2') do |config|
          config.vm.provision :shell, name: 'APT cache', inline: <<~BASH
            if [[ -d '/etc/apt' ]]; then
              tee '/etc/apt/apt.conf.d/02cache' <<APT
            Acquire::http::Proxy "http://${ip}:3142";
            Acquire::https::Proxy "false";
            APT
            fi
          BASH
        end
      '';
    xdg.configFile."gopass/config".text = toINI { } config.programs.gopass.settings;
    xdg.configFile."watchlog/config.scfg".text = ''
      delay: 1m
      permanent-delay: never
    '';
  };
}
