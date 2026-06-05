{ ... }:
{
  sane.programs.mimeo-query-desktop = {
    suggestedPrograms = [
      "mimeo"
    ];
    sandbox.extraHomePaths = [
      ".config/mimeo/associations.txt"
      ".local/share/applications"
    ];
  };
}
