{ ... }:
{
  sane.programs.lpa-gtk = {
    buildCost = 1;
    sandbox.method = null;  #< TODO: enable sandboxing
    suggestedPrograms = [ "lpac" ];
  };
}
