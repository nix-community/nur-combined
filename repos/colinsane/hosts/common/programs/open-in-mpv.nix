{ ... }:
{
  sane.programs.open-in-mpv = {
    # taken from <https://github.com/Baldomo/open-in-mpv>
    fs.".config/open-in-mpv/config.yml".symlink.text = ''
      players:
        mpv:
          name: mpv
          executable: mpv
          fullscreen: "--fs"
          pip: "--ontop --no-border --autofit=384x216 --geometry=98\\%:98\\%"
          enqueue: ""
          new_window: ""
          needs_ipc: true
          flag_overrides: {}
    '';
  };
}
