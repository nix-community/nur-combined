# curated mpv mods/scripts/users:
# - <https://github.com/stax76/awesome-mpv>
# mpv docs:
# - <https://mpv.io/manual/master>
# - <https://github.com/mpv-player/mpv/wiki>
# extensions i use:
# - <https://github.com/jonniek/mpv-playlistmanager>
# other extensions that could be useful:
# - list: <https://github.com/stax76/awesome-mpv>
# - list: <https://nudin.github.io/mpv-script-directory/>
# - browse DLNA shares: <https://github.com/chachmu/mpvDLNA>
# - act as a DLNS renderer (sink): <https://github.com/xfangfang/Macast>
# debugging:
# - enter console by pressing backtick.
#   > `set volume 50`     -> sets application volume to 50%
#   > `set ao-volume 50`  -> sets system-wide volume to 50%
#   > `show-text "vol: ${volume}"`  -> get the volume
# - show script output by running mpv with `--msg-level=all=trace`
#   - and then just `print(...)` from lua & it'll show in terminal
# - invoke mpv with `--no-config` to have it not read ~/.config/mpv/*
# - press `i` to show decoder info
#
# usage tips:
# - `<` or `>` to navigate prev/next-file-in-folder  (uosc)
# - shift+enter to view the playlist, then arrow-keys to navigate (mpv-playlistmanager)
{ config, lib, pkgs, ... }:

let
  cfg = config.sane.programs.mpv;
  uosc = pkgs.mpvScripts.uosc.overrideAttrs (upstream: {
    # patch so that the volume control corresponds to `ao-volume`, i.e. the system-wide volume.
    # this is particularly nice for moby, because it avoids the awkwardness that system volume
    # is hard to adjust while screen is on.
    # note that only under alsa (`-ao=alsa`) does `ao-volume` actually correspond to system volume.
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace src/uosc/main.lua \
        --replace-fail "mp.observe_property('volume'" "mp.observe_property('ao-volume'"
      substituteInPlace src/uosc/elements/Volume.lua \
        --replace-fail "mp.commandv('set', 'volume'" "mp.commandv('set', 'ao-volume'" \
        --replace-fail "mp.set_property_native('volume'" "mp.set_property('ao-volume'"

      # `ao-volume` isn't actually an observable property.
      # as of 2024/03/02, they *may* be working on that:
      # - <https://github.com/mpv-player/mpv/pull/13604#issuecomment-1971665736>
      # in the meantime, just query the volume every tick (i.e. frame).
      # alternative is mpv's JSON IPC feature, where i could notify its socket whenever pipewire volume changes.
      cat <<EOF >> src/uosc/main.lua
      function update_ao_volume()
        local vol = mp.get_property('ao-volume')
        if vol ~= nil then
          vol = tonumber(vol)
          if vol ~= state.volume then
            set_state('volume', vol)
            request_render()
          end
        end
      end
      -- tick seems to occur on every redraw (even when volume is hidden).
      -- in practice: for every new frame of the source, or whenever the cursor is moved.
      mp.register_event('tick', update_ao_volume)
      -- if paused and cursor isn't moving, then `tick` isn't called. fallback to a timer.
      mp.add_periodic_timer(2, update_ao_volume)
      -- invoke immediately to ensure state.volume is non-nil
      update_ao_volume()
      if state.volume == nil then
        state.volume = 0
      end
      EOF
    '';
  });
in
{
  sane.programs.mpv = {
    packageUnwrapped = with pkgs; wrapMpv mpv-unwrapped {
      scripts = [
        mpvScripts.mpris
        mpvScripts.mpv-playlistmanager
        uosc
        # pkgs.mpv-uosc-latest
      ];
      # extraMakeWrapperArgs = lib.optionals (cfg.config.vo != null) [
      #   # 2023/08/29: fixes an error where mpv on moby launches with the message
      #   #   "DRM_IOCTL_MODE_CREATE_DUMB failed: Cannot allocate memory"
      #   #   audio still works, and controls, screenshotting, etc -- just not the actual rendering
      #   #
      #   #   this is likely a regression for mpv 0.36.0.
      #   #   the actual error message *appears* to come from the mesa library, but it's tough to trace.
      #   #
      #   # 2024/03/02: no longer necessary, with mesa 23.3.1: <https://github.com/NixOS/nixpkgs/pull/265740>
      #   #
      #   # backend compatibility (2023/10/22):
      #   # run with `--vo=help` to see a list of all output options.
      #   # non-exhaustive (W=works, F=fails, A=audio-only, U=audio+ui only (no video))
      #   # ? null             Null video output
      #   # A (default)
      #   # A dmabuf-wayland   Wayland dmabuf video output
      #   # A libmpv           render API for libmpv  (mpv plays the audio, but doesn't even render a window)
      #   # A vdpau            VDPAU with X11
      #   # F drm              Direct Rendering Manager (software scaling)
      #   # F gpu-next         Video output based on libplacebo
      #   # F vaapi            VA API with X11
      #   # F x11              X11 (software scaling)
      #   # F xv               X11/Xv
      #   # U gpu              Shader-based GPU Renderer
      #   # W caca             libcaca  (terminal rendering)
      #   # W sdl              SDL 2.0 Renderer
      #   # W wlshm            Wayland SHM video output (software scaling)
      #   "--add-flags" "--vo=${cfg.config.vo}"
      # ];
    };

    suggestedPrograms = [
      "blast-to-default"
      "go2tv"
      "xdg-terminal-exec"
    ];

    sandbox.method = "bwrap";
    sandbox.autodetectCliPaths = true;
    sandbox.net = "all";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  #< mpris
    sandbox.whitelistDri = true;  #< mpv has excellent fallbacks to non-DRI, but DRI offers a good 30%-50% reduced CPU
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".config/mpv"  #< else mpris plugin crashes on launch
      ".local/share/applications"  #< for xdg-terminal-exec (go2tv)
      # it's common for album (or audiobook, podcast) images/lyrics/metadata to live adjacent to the primary file.
      # CLI detection is too poor to pick those up, so expose the common media dirs to the sandbox to make that *mostly* work.
      "Books/local"
      "Books/servo"
      "Music"
      "Videos/gPodder"
      "Videos/local"
      "Videos/servo"
    ];

    persist.byStore.plaintext = [
      # for `watch_later`
      ".local/state/mpv"
    ];
    fs.".config/mpv/scripts/sane/main.lua".symlink.target = ./sane-main.lua;
    fs.".config/mpv/input.conf".symlink.target = ./input.conf;
    fs.".config/mpv/mpv.conf".symlink.target = ./mpv.conf;
    fs.".config/mpv/script-opts/osc.conf".symlink.target = ./osc.conf;
    fs.".config/mpv/script-opts/console.conf".symlink.target = ./console.conf;
    fs.".config/mpv/script-opts/uosc.conf".symlink.target = ./uosc.conf;
    fs.".config/mpv/script-opts/playlistmanager.conf".symlink.target = ./playlistmanager.conf;

    # mime.priority = 200;  # default = 100; 200 means to yield to other apps
    mime.priority = 50;  # default = 100; 50 in order to take precedence over vlc.
    mime.associations."audio/flac" = "mpv.desktop";
    mime.associations."audio/mpeg" = "mpv.desktop";
    mime.associations."audio/x-opus+ogg" = "mpv.desktop";
    mime.associations."audio/x-vorbis+ogg" = "mpv.desktop";
    mime.associations."video/mp4" = "mpv.desktop";
    mime.associations."video/quicktime" = "mpv.desktop";
    mime.associations."video/webm" = "mpv.desktop";
    mime.associations."video/x-flv" = "mpv.desktop";
    mime.associations."video/x-matroska" = "mpv.desktop";
    mime.urlAssociations."^https?://(www.)?youtube.com/watch\?.*v=" = "mpv.desktop";
    mime.urlAssociations."^https?://(www.)?youtube.com/v/" = "mpv.desktop";
    mime.urlAssociations."^https?://(www.)?youtu.be/.+" = "mpv.desktop";
  };
}

