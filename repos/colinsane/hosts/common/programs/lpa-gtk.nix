{ ... }:
{
  sane.programs.lpa-gtk = {
    sandbox.method = null;  #< TODO: enable sandboxing
    suggestedPrograms = [ "lpac" ];
  };
}
