# TODO: when sandboxed, clicking a contact's address does not open the map
{ ... }: {
  sane.programs.gnome-contacts = {
    gsettings."org/gnome/Contacts" = {
      # else it will ask you to choose the default address book on each launch
      did-initial-setup = true;
    };

    sandbox.whitelistDbus = [ "user" ];  #< for OpenURI, evolution-data-server
    sandbox.whitelistDri = true;  #< speculative, but i'd like it to be responsive on mobile
    sandbox.whitelistWayland = true;

    suggestedPrograms = [
      "evolution-data-server"  #< REQUIRED for saving/loading of any contacts
    ];
  };
}
