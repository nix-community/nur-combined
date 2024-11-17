{ ... }:
{
  sane.programs.syshud = {
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      "/sys/class/backlight"  #< crashes if unable to access this directory
      # "/sys/devices"  #< only if you want it to actually show when the backlight changes
    ];

    fs.".config/sys64/hud/config.conf".symlink.text = ''
      [main]
      # position={bottom,left,right,top} to attach to the corresponding screen ege
      position=top
      orientation=h
      # width/height/icon_size are in pixels
      width=256
      height=39
      icon-size=32
      show-percentage=false
      # margin=0 will position below the sway bar, but on top of the window title
      margins=22 22 22 22
      # timeout: notifier will be dismissed after N seconds (integer only)
      timeout=1
      transition-time=0
      backlight=
      monitors=audio_in,audio_out
    '';
    fs.".config/sys64/hud/style.css".symlink.text = ''
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
      command = "syshud";
    };
  };
}
