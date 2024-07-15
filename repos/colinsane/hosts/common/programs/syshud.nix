{ ... }:
{
  sane.programs.syshud = {
    sandbox.method = "bwrap";
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      "/sys/class/backlight"  #< crashes if unable to access this directory
      # "/sys/devices"  #< only if you want it to actually show when the backlight changes
    ];

    fs.".config/sys64/hud.css".symlink.text = ''
      window {
        background: transparent;
      }
      window > box {
        background: #000000B4;
        border-radius: 19px;
      }
      label {
        color: #FFFFFF;
      }
      image {
        margin-left: 9px;
        color: #FFFFFFD0;
      }

      /* optionally, replace with `scale.horizontal` and `scale.vertical` for specialization */
      scale {
        margin: 0px;
        padding: 0px;
        margin-right: 7px;
      }
      scale trough {
        border-radius: 12px;
        background: #00000000;
        border: none;
        margin-left: 12px;
        margin-right: 12px;
      }
      scale highlight {
        margin-bottom: 3px;
        margin-top: 3px;
        border-radius: 12px;
        background: #e1f0efdc;
      }
      scale slider {
        margin: 0px;
        margin-left: -12px;
        margin-right: -12px;
        padding: 0px;
        /* background: #e1f0efFF; */
        background: #f9fffc;
        box-shadow: none;
        min-height: 25px;
        min-width: 25px;
      }
    '';

    services."syshud" = {
      description = "syshud: volume monitor/notifier";
      depends = [ "sound" ];  #< specifically wireplumber-pulse
      partOf = [ "graphical-session" ];

      # options:
      # -p {bottom,left,right,top}  to attach to the corresponding screen edge
      # -t N          for the notifier to be dismissed after N seconds (integer only)
      # -T N          reveal/hide transition time in milliseconds
      # -m N          to set the indicator this many pixels in from the edge.
      #               it considers sway bars, but not window titles
      # -{H,W} N      to set the height/width of the notifier, in px.
      # -i N          to set the size of the volume icon
      # -P            to hide percentage text
      command = "syshud -p top -t 1 -T 0 -m 22 -H 39 -W 256 -i 32 -P";
    };
  };
}
