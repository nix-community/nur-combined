{ ... }:
{
  sane.programs.blanket = {
    # com.rafaelmardojai.Blanket
    buildCost = 1;
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user.own = [
      "com.rafaelmardojai.Blanket"
      "org.mpris.MediaPlayer2.Blanket"
    ];
    sandbox.whitelistWayland = true;
  };
}
