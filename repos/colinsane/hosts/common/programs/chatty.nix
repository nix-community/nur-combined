{ pkgs, ... }:
let
  chattyNoOauth = pkgs.chatty.override {
    # the OAuth feature (presumably used for web-based logins) pulls a full webkitgtk.
    # especially when using the gtk3 version of evolution-data-server, it's an ancient webkitgtk_4_1.
    # disable OAuth for a faster build & smaller closure
    evolution-data-server = pkgs.evolution-data-server.override {
      enableOAuth2 = false;
      gnome-online-accounts = pkgs.gnome-online-accounts.override {
        # disables the upstream "goabackend" feature -- presumably "Gnome Online Accounts Backend"
        # frees us from webkit_4_1, in turn.
        enableBackend = false;
        gvfs = pkgs.gvfs.override {
          # saves 20 minutes of build time, for unused feature
          samba = null;
        };
      };
    };
  };
  chatty-latest = pkgs.chatty-latest.override {
    evolution-data-server-gtk4 = pkgs.evolution-data-server-gtk4.override {
      gnome-online-accounts = pkgs.gnome-online-accounts.override {
        # disables the upstream "goabackend" feature -- presumably "Gnome Online Accounts Backend"
        # frees us from webkit_4_1, in turn.
        enableBackend = false;
        gvfs = pkgs.gvfs.override {
          # saves 20 minutes of build time and cross issues, for unused feature
          samba = null;
        };
      };
    };
  };
in
{
  sane.programs.chatty = {
    # package = chattyNoOauth;
    package = chatty-latest;
    suggestedPrograms = [ "gnome-keyring" ];
    persist.byStore.private = [
      ".local/share/chatty"  # matrix avatars and files
      # not just XMPP; without this Chatty will regenerate its device-id every boot.
      # .purple/ contains XMPP *and* Matrix auth, logs, avatar cache, and a bit more
      ".purple"
    ];
  };
}
