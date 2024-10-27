{ config, lib, pkgs, ... }:

let
  inherit (builtins) listToAttrs;
  inherit (config) host;
  inherit (lib) foldlAttrs imap0 nameValuePair;
  inherit (lib.generators) toKeyValue;
  inherit (lib.hm.gvariant) mkTuple mkUint32;

  palette = import ../resources/palette.nix { inherit lib pkgs; };

  toTOML = (pkgs.formats.toml { }).generate;
in
{
  imports = [
    ../../packages/nautilus-scripts.nix
    ../../packages/organize-downloads.nix
  ];

  config = {
    # Unfree packages
    allowedUnfree = [
      "vagrant"
    ];

    # Associations
    xdg.mimeApps = {
      enable = true;
      defaultApplications = foldlAttrs (byType: handler: types: byType // (listToAttrs (map (type: nameValuePair type handler) types))) { } {
        "codium.desktop" = [ "application/gpx+xml" "application/json" "application/rss+xml" "application/x-shellscript" "application/xml" "message/rfc822" "text/markdown" "text/plain" ];
        "firefox.desktop" = [ "application/xhtml+xml" "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
        "org.gnome.Evince.desktop" = [ "application/pdf" ];
        "org.gnome.FileRoller.desktop" = [ "application/zip" ];
        "org.gnome.Loupe.desktop" = [ "image/avif" "image/bmp" "image/gif" "image/heif" "image/jpeg" "image/png" "image/svg+xml" "image/tiff" "image/webp" ];
        "org.gnome.Totem.desktop" = [ "video/mp4" "video/webm" "video/x-matroska" ];
        "writer.desktop" = [ "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ];
      };
    };
    xdg.configFile."mimeapps.list".force = true; # Workaround for nix-community/home-manager#1213

    # Modules
    programs.jq.enable = true;
    programs.ssh = {
      enable = true;
      includes = [ "config.d/*" ];
      extraOptionOverrides = {
        GSSAPIAuthentication = "no";
        PreferredAuthentications = "publickey";
      };
    };

    # Packages
    home.packages = with pkgs; [
      add-words
      binsider
      cavif
      darktable
      gnome.dconf-editor
      dig
      displaycal
      duperemove
      efficient-compression-tool
      exiftool
      eyedropper
      fd
      ffmpeg
      file
      fq
      gdu
      gifsicle
      gimp-with-plugins
      gopass
      gopass-env
      gopass-ydotool
      gtk4-icon-browser
      guetzli
      guvcview
      htop
      httpie
      identity
      imagemagickBig
      img2pdf
      (inkscape-with-extensions.override { inkscapeExtensions = with inkscape-extensions; [ applytransforms ]; })
      ipcalc
      just
      just-local
      killall
      libwebp # cwebp
      lsof
      magic-wormhole
      miller
      moreutils
      mozjpeg-simple
      mtr
      multitail
      nix-top
      nix-tree
      nixpkgs-review
      off
      okular
      pdfarranger
      pngquant
      pngtools
      poppler_utils # pdfinfo
      pup
      pwgen
      qalculate-gtk
      ripgrep
      rsync
      s-tui
      sqlitebrowser
      nodePackages.svgo
      trash-cli
      uniscribe
      unln
      usbutils
      v4l-utils
      vagrant
      visidata
      vivictpp
      watchlog
      wev
      whois
      wireguard-tools
      wl-clipboard
      xkcdpass
      xorg.xev
      yq
    ];

    # Nautilus scripts
    nautilusScripts = with pkgs; {
      "HEIF,PNG,TIFF → JPEG".xargs = "-n 1 -P 8 nice ${mozjpeg-simple}/bin/mozjpeg";
      "JPEG: Strip geolocation".xargs = "nice ${exiftool}/bin/exiftool -overwrite_original -gps:all= -xmp:geotag=";
      "PNG: Optimize".xargs = ''
        nice ${efficient-compression-tool}/bin/ect -8 -keep -quiet --mt-file \
        2> >(${gnome.zenity}/bin/zenity --width 600 --progress --pulsate --auto-close --auto-kill)
      '';
      "PNG: Quantize".each = ''
        ${pngquant-interactive}/bin/pngquant-interactive --suffix '.qnt' "$path"
        nice ${efficient-compression-tool}/bin/ect -8 -keep -quiet "''${path%.png}.qnt.png"
      '';
      "PNG: Trim".xargs = "-n 1 -P 8 nice ${imagemagick}/bin/mogrify -trim";
    };

    # Configuration
    home.sessionVariables = {
      ANSIBLE_NOCOWS = "🐄"; # Workaround for ansible/ansible#10530
      PYTHON_KEYRING_BACKEND = "keyring.backends.fail.Keyring"; # Workaround for python-poetry/poetry#8761
      VAGRANT_APT_CACHE = "http://10.0.2.3:3142";
    };
    xdg.configFile."autostart/emote.desktop".source = "${pkgs.emote}/share/applications/emote.desktop";
    xdg.configFile."cargo-release/release.toml".source = toTOML "release.toml" {
      push = false;
      publish = false;
      pre-release-commit-message = "Version {{version}}";
      tag-message = "Version {{version}}";
    };
    xdg.configFile."gdu/gdu.yaml".text = "no-cross: true";
    home.file.".npmrc".text = toKeyValue { } { fund = false; update-notifier = false; };
    xdg.configFile."rustfmt/rustfmt.toml".source = toTOML "rustfmt.toml" {
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
          "6" = [ red orange yellow green blue purple ];
          "8" = [ red vermilion orange yellow green teal blue purple ];
          "12" = [ red red-dim orange orange-dim yellow yellow-dim green green-dim blue blue-dim purple purple-dim ];
          "16" = [ red red-dim vermilion vermilion-dim orange orange-dim yellow yellow-dim green green-dim teal teal-dim blue blue-dim purple purple-dim ];
        }."${toString host.cores}"
      );
      mem-color = orange;
      swap-color = purple;
      net-in-color = blue;
      net-out-color = red;
    };
    home.file.".vagrant.d/Vagrantfile".text = ''
      Vagrant.configure('2') do |config|
        if ENV.include?('VAGRANT_APT_CACHE')
          config.vm.provision :shell, name: 'APT cache', inline: <<~BASH
            tee '/etc/apt/apt.conf.d/02cache' <<APT
            Acquire::http::Proxy "#{ENV['VAGRANT_APT_CACHE']}";
            Acquire::https::Proxy "false";
            APT
          BASH
        else
          config.trigger.before :up, warn: 'Set VAGRANT_APT_CACHE to use an APT caching proxy'
        end
      end
    '';
    home.file.".visidatarc".text = with pkgs; toKeyValue { } {
      "options.clipboard_copy_cmd" = "${wl-clipboard}/bin/wl-copy";
      "options.clipboard_paste_cmd" = "${wl-clipboard}/bin/wl-paste --no-newline";
    };
    xdg.configFile."watchlog/config.scfg".text = ''
      delay: 1m
      permanent-delay: never
    '';
  };
}
