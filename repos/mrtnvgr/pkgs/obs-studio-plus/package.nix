{ wrapOBS, obs-studio-plugins }:

wrapOBS {
  plugins = with obs-studio-plugins; [
    wlrobs
    obs-backgroundremoval
    obs-pipewire-audio-capture
    obs-vaapi
    obs-vkcapture
  ];
}
