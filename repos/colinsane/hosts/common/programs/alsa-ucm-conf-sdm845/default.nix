{ ... }:
{
  sane.programs.alsa-ucm-pocophone = {
    sandbox.enable = false;  #< only provides /share/alsa
  };
}
