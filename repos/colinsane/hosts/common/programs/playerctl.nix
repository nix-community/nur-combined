{ ... }:
{
  sane.programs.playerctl = {
    sandbox.wrapperType = "inplace";  #< /lib/pkgconfig/playerctl.pc refers to $out by full path
    sandbox.whitelistDbus = [ "user" ];  # notifications

    services.playerctld = {
      description = "playerctl daemon to keep track of which MPRIS players were recently active";
      documentation = [ "https://github.com/altdesktop/playerctl/issues/161" ];
      partOf = [ "default" ];  #< TODO: maybe better to zero `wantedBy` here and have the specific consumers (e.g. swaync) explicitly depend on this.
      command = "playerctld";
      # readiness.waitDbus = "org.mpris.MediaPlayer2.Player";  #< doesn't work... did the endpoint change?
    };
  };
}
