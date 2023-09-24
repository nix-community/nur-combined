# mpv docs:
# - <https://mpv.io/manual/master>
# - <https://github.com/mpv-player/mpv/wiki>
# curated mpv mods/scripts/users:
# - <https://github.com/stax76/awesome-mpv>
{ pkgs, ... }:

{
  sane.programs.mpv = {
    package = pkgs.wrapMpv pkgs.mpv-unwrapped {
      scripts = with pkgs.mpvScripts; [
        mpris
        # uosc
        pkgs.mpv-uosc-latest
      ];
      extraMakeWrapperArgs = [
        # 2023/08/29: fixes an error where mpv on moby launches with the message
        #   "DRM_IOCTL_MODE_CREATE_DUMB failed: Cannot allocate memory"
        #   audio still works, and controls, screenshotting, etc -- just not the actual rendering
        # this is likely a regression for mpv 0.36.0.
        # the actual error message *appears* to come from the mesa library, but it's tough to trace.
        # run with `--vo=help` to see a list of all output options.
        # non-exhaustive (F=fails, W=works)
        # ? libmpv           render API for libmpv
        # ? gpu              Shader-based GPU Renderer
        # ? gpu-next         Video output based on libplacebo
        # ? vdpau            VDPAU with X11
        # ? wlshm            Wayland SHM video output (software scaling)
        # ? xv               X11/Xv
        # W sdl              SDL 2.0 Renderer
        # F dmabuf-wayland   Wayland dmabuf video output
        # ? vaapi            VA API with X11
        # ? x11              X11 (software scaling)
        # ? null             Null video output
        # ? caca             libcaca
        # F drm              Direct Rendering Manager (software scaling)
        "--add-flags" "--vo=sdl"
      ];
    };
    persist.plaintext = [ ".local/state/mpv/watch_later" ];
    fs.".config/mpv/input.conf".symlink.text = ''
      # let volume/power keys be interpreted by the system.
      # this is important for sxmo.
      # mpv defaults is POWER = close, VOLUME_{UP,DOWN} = adjust application-level volume
      POWER ignore
      VOLUME_UP ignore
      VOLUME_DOWN ignore
    '';
    fs.".config/mpv/mpv.conf".symlink.text = ''
      save-position-on-quit=yes
      keep-open=yes

      # force GUI, even for tracks w/o album art
      # see: <https://www.reddit.com/r/mpv/comments/rvrrpt/oscosdgui_and_arch_linux/>
      player-operation-mode=pseudo-gui

      # use uosc instead (for On Screen Controls)
      osc=no
      # uosc provides its own seeking/volume indicators, so you also don't need this
      osd-bar=no
      # uosc will draw its own window controls if you disable window border
      border=no
    '';
    fs.".config/mpv/script-opts/osc.conf".symlink.text = ''
      # make the on-screen controls *always* visible
      # unfortunately, this applies to full-screen as well
      # - docs: <https://mpv.io/manual/master/#on-screen-controller-visibility>
      # if uosc is installed, this file is unused
      visibility=always
    '';
    fs.".config/mpv/script-opts/uosc.conf".symlink.text = let
      play_pause_btn = "cycle:play_arrow:pause:no=pause/yes=play_arrow";
      rev_btn = "command:replay_10:seek -10";
      fwd_btn = "command:forward_30:seek 30";
    in ''
      # docs:
      # - <https://github.com/tomasklaen/uosc>
      # - <https://superuser.com/questions/1775550/add-new-buttons-to-mpv-uosc-ui>
      timeline_style=bar
      timeline_persistency=paused,audio
      controls_persistency=paused,audio
      volume_persistency=audio
      volume_opacity=0.75

      # speed_persistency=paused,audio
      # vvv  want a close button?
      top_bar=always
      top_bar_persistency=paused

      controls=menu,<video>subtitles,<has_many_audio>audio,<has_many_video>video,<has_many_edition>editions,<stream>stream-quality,space,${rev_btn},${play_pause_btn},${fwd_btn},space,speed:1.0,gap,<video>fullscreen

      text_border=6.0
      font_bold=yes
      background_text=ff8080
      foreground=ff8080

      ui_scale=1.0
    '';

    # mime.priority = 200;  # default = 100; 200 means to yield to other apps
    mime.priority = 50;  # default = 100; 50 in order to take precedence over vlc.
    mime.associations."audio/flac" = "mpv.desktop";
    mime.associations."audio/mpeg" = "mpv.desktop";
    mime.associations."audio/x-vorbis+ogg" = "mpv.desktop";
    mime.associations."video/mp4" = "mpv.desktop";
    mime.associations."video/quicktime" = "mpv.desktop";
    mime.associations."video/webm" = "mpv.desktop";
    mime.associations."video/x-matroska" = "mpv.desktop";
  };
}

