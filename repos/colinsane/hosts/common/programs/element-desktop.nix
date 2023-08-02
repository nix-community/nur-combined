{ ... }:
{
  sane.programs.element-desktop = {
    # creds/session keys, etc
    persist.private = [ ".config/Element" ];

    suggestedPrograms = [ "gnome-keyring" ];
  };
}
