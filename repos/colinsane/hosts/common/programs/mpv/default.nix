# curated mpv mods/scripts/users:
# - <https://github.com/stax76/awesome-mpv>
# mpv docs:
# - <https://mpv.io/manual/master>
# - <https://github.com/mpv-player/mpv/wiki>
# extensions i use:
# - <https://github.com/jonniek/mpv-playlistmanager>
# - <https://github.com/ekisu/mpv-webm>
# - <https://github.com/mfcc64/mpv-scripts/blob/master/visualizer.lua>
# other extensions that could be useful:
# - list: <https://github.com/stax76/awesome-mpv>
# - list: <https://nudin.github.io/mpv-script-directory/>
# - browse DLNA shares: <https://github.com/chachmu/mpvDLNA>
# - act as a DLNA renderer (sink): <https://github.com/xfangfang/Macast>
# - update watch_later periodically -- not just on exit: <https://gist.github.com/CyberShadow/2f71a97fb85ed42146f6d9f522bc34ef>
#   - <https://github.com/AN3223/dotfiles/blob/master/.config/mpv/scripts/auto-save-state.lua>
# - touch shortcuts (double-tap L/R portions of window to seek, etc): <https://github.com/christoph-heinrich/mpv-touch-gestures>
#   - <https://github.com/omeryagmurlu/mpv-gestures>
# - jellyfin client: <https://github.com/EmperorPenguin18/mpv-jellyfin>
#   - DLNA client (player only: no casting): <https://github.com/chachmu/mpvDLNA>
# - search videos on Youtube: <https://github.com/rozari0/mpv-youtube-search>
#   - <https://github.com/CogentRedTester/mpv-scripts/blob/master/youtube-search.lua>
# - sponsorblock: <https://codeberg.org/jouni/mpv_sponsorblock_minimal>
# - screenshot-to-clipboard: <https://github.com/zc62/mpv-scripts/blob/master/screenshot-to-clipboard.js>
# - mpv-as-image-viewer: <https://github.com/guidocella/mpv-image-config>
# debugging:
# - enter console by pressing backtick.
#   > `set volume 50`     -> sets application volume to 50%
#   > `set ao-volume 50`  -> sets system-wide volume to 50%
#   > `show-text "vol: ${volume}"`  -> get the volume
# - show script output by running mpv with `--msg-level=all=trace`
#   - and then just `print(...)` from lua & it'll show in terminal
#   - requires that mpv.conf NOT include player-operation-mode=pseudo-gui
# - invoke mpv with `--no-config` to have it not read ~/.config/mpv/*
# - press `i` to show decoder info
#
# usage tips:
# - `<` or `>` to navigate prev/next-file-in-folder  (uosc)
# - shift+enter to view the playlist, then arrow-keys to navigate (mpv-playlistmanager)
{ config, lib, pkgs, ... }:

let
  cfg = config.sane.programs.mpv;
  uosc = pkgs.mpvScripts.uosc.overrideAttrs (upstream: rec {
    # version = "5.2.0-unstable-2024-05-07";
    # src = lib.warnIf (lib.versionOlder "5.2.0" upstream.version) "uosc outdated; remove patch?" pkgs.fetchFromGitHub {
    #   owner = "tomasklaen";
    #   repo = "uosc";
    #   rev = "2940352fade2c4f7bf68b1ef8381bef83058f9f7";
    #   hash = "sha256-tQq6ycxHXhTYSRBIz73o5VlKRBCoJ5yu59AdZik5Oos=";
    # };
    # src = pkgs.fetchFromGitea {
    #   domain = "git.uninsane.org";
    #   owner = "colin";
    #   repo = "uosc";
    #   rev = "dev-sane-5.2.0";
    #   hash = "sha256-lpqk4nnCxDZr/Y7/seM4VyR30fVrDAT4VP7C8n88lvA=";
    # };

    # tools = pkgs.buildGoModule {
    #   pname = "uosc-bin";
    #   inherit version src;
    #   vendorHash = "sha256-nkY0z2GiDxfNs98dpe+wZNI3dAXcuHaD/nHiZ2XnZ1Y=";
    # };

    postPatch = (upstream.postPatch or "") + ''
      ### patch so touch controls work well with sway 1.9+
      ### in particular, "mouse.hover" is *always* false for touch events (i guess this is a bug in mpv?)
      ### and a touch release event is always followed by a mouse move to the cursor (that's a sway thing) which doesn't make sense.
      # 1. always listen for mbtn_left events, even before a hover event would activate a zone:
      substituteInPlace src/uosc/lib/cursor.lua \
        --replace-fail \
          "if binding and cursor:collides_with(zone.hitbox)" \
          "if binding"
      # 2. uosc already simulates mouse movements on touch down, but because of the hover handling, they get misunderstood as mouse leaves.
      #    so, bypass the cursor:leave() check.
      substituteInPlace src/uosc/lib/cursor.lua \
        --replace-fail \
          "handle_mouse_pos(nil, mp.get_property_native('mouse-pos'))" \
          "local mpos = mp.get_property_native('mouse-pos')
           cursor:move(mpos.x, mpos.y)
           cursor.hover_raw = mpos.hover"
      # 3. explicitly fire a cursor:leave on touch release, so that all zones are deactivated (and control visibility goes back to default state)
      substituteInPlace src/uosc/lib/cursor.lua \
        --replace-fail \
          "cursor:create_handler('primary_up', create_shortcut('primary_up', mods))" \
          "function()
             cursor:trigger('primary_up', create_shortcut('primary_up', mods))
             if not cursor.hover_raw then
               cursor:leave()
             end
           end"
      # 4. sometimes we get a touch movement shortly AFTER touch is released:
      #    detect that and ignore it
      substituteInPlace src/uosc/lib/cursor.lua \
        --replace-fail \
          "cursor:move(mouse.x, mouse.y)" \
          "local last_down = cursor.last_events['primary_down'] or { time = 0 }
           local last_up = cursor.last_events['primary_up'] or { time = 0 }
           if cursor.hover_raw or last_down.time >= last_up.time then cursor:move(mouse.x, mouse.y) end"

      ### patch so that uosc volume control is routed to sane_sysvol.
      ### this is particularly nice for moby, because it avoids the awkwardness that system volume
      ### is hard to adjust while screen is on.
      ### previously i used ao-volume instead of sane_sysvol: but that forced `ao=alsa`
      ### and came with heavy perf penalties (especially when adjusting the volume)
      substituteInPlace src/uosc/main.lua \
        --replace-fail \
          "mp.observe_property('volume'" \
          "mp.observe_property('user-data/sane_sysvol/volume'" \
        --replace-fail \
          "mp.observe_property('mute'" \
          "mp.observe_property('user-data/sane_sysvol/mute'"
      substituteInPlace src/uosc/elements/Volume.lua \
        --replace-fail \
          "mp.commandv('set', 'volume'" \
          "mp.set_property_number('user-data/sane_sysvol/volume'" \
        --replace-fail \
          "mp.set_property_native('volume'" \
          "mp.set_property_number('user-data/sane_sysvol/volume'" \
        --replace-fail \
          "mp.set_property_native('mute'" \
          "mp.set_property_bool('user-data/sane_sysvol/mute'" \
        --replace-fail \
          "mp.commandv('cycle', 'mute')" \
          "mp.set_property_bool('user-data/sane_sysvol/mute', not mp.get_property_bool('user-data/sane_sysvol/mute'))"

      # tweak the top-bar "maximize" button to actually act as a "fullscreen" button.
      substituteInPlace src/uosc/elements/TopBar.lua \
        --replace-fail \
          'set fullscreen no;set window-maximized no' \
          'set fullscreen no'
      substituteInPlace src/uosc/elements/TopBar.lua \
        --replace-fail \
          'set window-maximized yes' \
          'set fullscreen yes'
      # substituteInPlace src/uosc/elements/TopBar.lua \
      #   --replace-fail \
      #     'get_maximized_command,' \
      #     '"cycle fullscreen",'
    '';
  });
  # visualizer = pkgs.mpvScripts.visualizer.overrideAttrs (upstream: {
  #   postPatch = (upstream.postPatch or "") + ''
  #     # don't have the script register its own keybinding: i'll do it manually via input.conf.
  #     # substituteInPlace visualizer.lua --replace-fail \
  #     #   'mp.add_key_binding' '-- mp.add_key_binding'
  #     substituteInPlace visualizer.lua --replace-fail \
  #       'cycle_key = "c"' 'cycle_key = "v"'
  #   '';
  # });
in
{
  sane.programs.mpv = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
          defaultProfile = mkOption {
            type = types.enum [ "high-quality" "mid-range" "fast" ];
            default = "mid-range";
            description = ''
              default mpv profile to use. this effects defaults such as:
              - youtube stream settings.
              - demuxer read-ahead (i.e. how much of the file/stream to read into RAM).
              see my `mpv.conf` for details
            '';
          };
        };
      };
    };
    packageUnwrapped = pkgs.mpv-unwrapped.wrapper {
      mpv = pkgs.mpv-unwrapped.override rec {
        # ffmpeg = pkgs.ffmpeg.override {
        #   # to enable spatial audio, i.e. downmixing 7.1 -> 2.0.
        #   # but nowadays i route surround staright out of mpv and do the downmixing in pipewire instead.
        #   withMysofa = true;
        # };
        # N.B.: populating `self` to `luajit` is necessary for the resulting `lua.withPackages` function to preserve my override.
        # i use enable52Compat in order to get `table.unpack`.
        # i think using `luajit` here instead of `lua` is optional, just i get better perf with it :)
        lua = pkgs.luajit.override { enable52Compat = true; self = lua; };
      };
      scripts = with pkgs.mpv-unwrapped; [
        scripts.mpris
        (scripts.mpv-gallery-view.override {
          # mpv-gallery-view: press `g` for grid view of the playlist, with thumbnails.
          # extraThumbgens = how many images to generate thumbnails for in parallel (+1 implied)
          extraThumbgens = {
            fast = 1;
            mid-range = 7;
            high-quality = 15;
          }.${cfg.config.defaultProfile};
        })
        scripts.mpv-image-viewer.image-positioning
        scripts.mpv-playlistmanager
        scripts.mpv-webm
        scripts.sane_cast
        scripts.sane_sysvol
        scripts.sponsorblock
        uosc
        # visualizer  #< XXX(2024-07-23): `visualizer` breaks auto-play-next-track (only when visualizations are disabled)
        # pkgs.mpv-uosc-latest
      ];
    };

    suggestedPrograms = [
      "sane-cast"
      "sane-die-with-parent"
      "xdg-terminal-exec"
      "yt-dlp"
    ];

    sandbox.autodetectCliPaths = "parent";  #< especially for subtitle downloader; also nice for viewing albums
    sandbox.net = "all";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user.own = [ "org.mpris.MediaPlayer2.mpv" "org.mpris.MediaPlayer2.mpv.*" ];
    sandbox.whitelistDri = true;  #< mpv has excellent fallbacks to non-DRI, but DRI offers a good 30%-50% reduced CPU
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".config/mpv"  #< else mpris plugin crashes on launch
      ".config/yt-dlp"
      ".local/share/applications"  #< for xdg-terminal-exec (sane-cast)
      # it's common for album (or audiobook, podcast) images/lyrics/metadata to live adjacent to the primary file.
      # CLI detection is too poor to pick those up, so expose the common media dirs to the sandbox to make that *mostly* work.
      "Books/Audiobooks"
      "Books/Visual"
      "Books/local"
      "Books/servo"
      "Music"
      "Videos/gPodder"
      "Videos/local"
      "Videos/servo"
    ];
    sandbox.mesaCacheDir = ".cache/mpv/mesa";

    persist.byStore.ephemeral = [
      ".cache/thumbnails/mpv-gallery"  # only if mpv-gallery-view is enabled
    ];
    persist.byStore.plaintext = [
      # for `watch_later`
      ".local/state/mpv"
    ];
    persist.byStore.private = [
      "Videos/mpv"
    ];

    fs.".config/mpv/input.conf".symlink.target = ./input.conf;
    fs.".config/mpv/mpv.conf".symlink.target = pkgs.replaceVars ./mpv.conf {
      inherit (cfg.config) defaultProfile;
    };
    fs.".config/mpv/script-opts/console.conf".symlink.target = ./console.conf;
    fs.".config/mpv/script-opts/osc.conf".symlink.target = ./osc.conf;
    fs.".config/mpv/script-opts/playlistmanager.conf".symlink.target = ./playlistmanager.conf;
    fs.".config/mpv/script-opts/sponsorblock.conf".symlink.target = ./sponsorblock.conf;
    fs.".config/mpv/script-opts/uosc.conf".symlink.target = ./uosc.conf;
    fs.".config/mpv/script-opts/visualizer.conf".symlink.target = ./visualizer.conf;
    fs.".config/mpv/script-opts/webm.conf".symlink.target = ./webm.conf;

    # mime.priority = 200;  # default = 100; 200 means to yield to other apps
    mime.priority = 50;  # default = 100; 50 in order to take precedence over vlc.
    mime.associations."audio/amr" = "mpv.desktop";  #< GSM, e.g. voicemail files
    mime.associations."audio/flac" = "mpv.desktop";
    mime.associations."audio/mpeg" = "mpv.desktop";
    mime.associations."audio/x-opus+ogg" = "mpv.desktop";
    mime.associations."audio/x-vorbis+ogg" = "mpv.desktop";
    mime.associations."video/mp4" = "mpv.desktop";
    mime.associations."video/quicktime" = "mpv.desktop";
    mime.associations."video/webm" = "mpv.desktop";
    mime.associations."video/x-flv" = "mpv.desktop";
    mime.associations."video/x-matroska" = "mpv.desktop";
    #v be the opener for YouTube videos
    mime.urlAssociations."^https?://(m\.)?(www\.)?(music\.)?youtu.be/.+$" = "mpv.desktop";
    mime.urlAssociations."^https?://(m\.)?(www\.)?(music\.)?youtube.com/embed/.+$" = "mpv.desktop";
    mime.urlAssociations."^https?://(m\.)?(www\.)?(music\.)?youtube.com/playlist\?.*list=.+$" = "mpv.desktop";
    mime.urlAssociations."^https?://(m\.)?(www\.)?(music\.)?youtube.com/shorts/.+$" = "mpv.desktop";
    mime.urlAssociations."^https?://(m\.)?(www\.)?(music\.)?youtube.com/v/.+$" = "mpv.desktop";
    mime.urlAssociations."^https?://(m\.)?(www\.)?(music\.)?youtube.com/watch\?.*v=.+$" = "mpv.desktop";
    mime.urlAssociations."^https?://(m\.)?(www\.)?facebook.com/reel/.+$" = "mpv.desktop";
    #v be the opener for Tiktok
    mime.urlAssociations."^https?://(www\.)?tiktok.com/@.*/video/.+$" = "mpv.desktop";
    #v be the opener for A/V, generally. useful for e.g. feed readers like News Flash which open content through the portal
    #  also allows right-click -> xdg-open to open embedded videos
    mime.urlAssociations."^https?://.*\.(mp3|mp4|ogg|ogv|opus|webm)(\\?.*)?$" = "mpv.desktop";
    #v Loupe image viewer can't open URIs, so use mpv instead
    mime.urlAssociations."^https?://i\.imgur.com/.+$" = "mpv.desktop";
    mime.urlAssociations."^https?://.*\.(gif|heif|jpeg|jpg|png|svg|webp)(\\?.*)?$" = "mpv.desktop";
  };

  sane.programs.yt-dlp.config = lib.mkIf cfg.enabled {
    defaultProfile = lib.mkDefault cfg.config.defaultProfile;
  };
}
