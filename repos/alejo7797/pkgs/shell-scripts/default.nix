{
  lib,
  writeShellApplication,
  bc,
  imagemagick,
  jq,
  pipewire,
  wireplumber,
}:

{
  audio-switch = writeShellApplication {
    name = "audio-switch";
    text = builtins.readFile ./audio-switch.sh;
    runtimeInputs = [
      jq
      pipewire
      wireplumber
    ];
    meta = {
      description = "Shell script to switch between available audio outputs";
      license = lib.licenses.mit;
      homepage = "https://codeberg.org/alejo7797/nix-expressions";
    };
  };

  round-corners = writeShellApplication {
    name = "round-corners";
    text = builtins.readFile ./round-corners.sh;
    runtimeInputs = [
      bc
      imagemagick
    ];
    meta = {
      description = "Shell script to round off an image's corners";
      license = lib.licenses.mit;
      homepage = "https://codeberg.org/alejo7797/nix-expressions";
    };
  };
}
