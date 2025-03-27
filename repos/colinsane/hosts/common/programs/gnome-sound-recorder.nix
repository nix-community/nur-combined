{ ... }:
{
  sane.programs.gnome-sound-recorder = {
    sandbox.wrapperType = "inplace";  #< the binary lives in `share/org.gnome.SoundRecorder`, for some reason.
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".local/share/org.gnome.SoundRecorder"  #< this is where it saves recordings
      # additionally, gnome-sound-recorder has the option to "export" audio out of this directory:
      # opens a file chooser for where to save the file (maybe via the portal??)
    ];
  };
}
