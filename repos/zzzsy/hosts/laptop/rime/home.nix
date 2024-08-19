let
  #dir = ".config/ibus/rime";
  dir = ".local/share/fcitx5/rime";
in
{
  home.file."${dir}" = {
    source = ./custom;
    recursive = true;
  };
}
