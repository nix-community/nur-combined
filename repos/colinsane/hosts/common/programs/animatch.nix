# debug with:
# - `animatch --debug`
# - `gdb animatch`
# try:
# - `animatch --fullscreen`
# - `animatch --windowed`
# the other config options (e.g. verbose logging -- which doesn't seem to do anything) have to be configured via .ini file
# ```ini
# # ~/.config/Holy Pangolin/Animatch/SuperDerpy.ini
# [SuperDerpy]
# debug=1
# disableTouch=1
# [game]
# verbose=1
# ```
{ pkgs, ... }:
{
  sane.programs.animatch = {
    packageUnwrapped = with pkgs; animatch.override {
      # allegro has no native wayland support, and so by default crashes when run without Xwayland.
      # enable the allegro SDL backend, and achieve Wayland support via SDL's Wayland support.
      allegro5 = allegro5.override { useSDL = true; };
    };
    # nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
    #   makeWrapper
    # ];
    # postFixup = (upstream.postFixup or "") + ''
    #   wrapProgram $out/bin/animatch \
    #     --set SDL_VIDEODRIVER wayland
    # '';

    buildCost = 1;

    sandbox.whitelistWayland = true;

    persist.byStore.plaintext = [
      # ".config/Holy Pangolin/Animatch"  #< used for SuperDerpy config (e.g. debug, disableTouch, fullscreen, enable sound, etc). SuperDerpy.ini
      ".local/share/Holy Pangolin/Animatch"  #< used for game state (level clears). SuperDerpy.ini
    ];
  };
}
