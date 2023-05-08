{ ... }:

{
  sane.programs.mpv = {
    persist.plaintext = [ ".config/mpv/watch_later" ];
    # format is <key>=%<length>%<value>
    fs.".config/mpv/mpv.conf".symlink.text = ''
      save-position-on-quit=%3%yes
      keep-open=%3%yes
    '';
  };
}

