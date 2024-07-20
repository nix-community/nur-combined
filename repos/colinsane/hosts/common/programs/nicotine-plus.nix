# soulseek music sharing GUI app
{ ... }:
{
  sane.programs.nicotine-plus = {
    sandbox.method = "bwrap";
    sandbox.whitelistDri = true;  #< required, else it fails to launch the gui
    sandbox.whitelistWayland = true;
    sandbox.net = "vpn";
    sandbox.extraHomePaths = [
      "Music"
      # on run, nicotine will try to move the initial config to `config.old`
      # and then update the config on disk. it errors if it can't `mv` it like that.
      ".config/nicotine"
    ];

    # the config has loooads of options, but the only critical one is auth/creds.
    # run with ~/.config/nicotine in the sandbox and nicotine will derive the whole config
    # and write back *all* options for you to then edit further.
    secrets.".config/nicotine/config" = ../../../secrets/common/nicotine-config.bin;
    persist.byStore.plaintext = [
      ".local/share/nicotine/downloads"
    ];
  };
}
