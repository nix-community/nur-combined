{ pkgs, ... }:
{
  sane.programs.chatty = {
    # packageUnwrapped = chattyNoOauth;
    packageUnwrapped = pkgs.chatty-latest;
    suggestedPrograms = [ "gnome-keyring" ];
    persist.byStore.private = [
      ".local/share/chatty"  # matrix avatars and files
      # not just XMPP; without this Chatty will regenerate its device-id every boot.
      # .purple/ contains XMPP *and* Matrix auth, logs, avatar cache, and a bit more
      ".purple"
    ];
  };
}
