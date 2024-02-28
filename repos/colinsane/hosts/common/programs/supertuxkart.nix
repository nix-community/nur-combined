{ ... }:
{
  sane.programs.superTuxKart = {
    sandbox.method = "bwrap";
    sandbox.net = "clearnet";  # net play
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;

    persist.byStore.plaintext = [
      ".cache/supertuxkart"
      ".config/supertuxkart"
      ".local/share/supertuxkart"
    ];
  };
}
