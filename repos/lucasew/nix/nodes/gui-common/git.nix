{pkgs, ...}:
let
  deltaBin = "${pkgs.delta}/bin/delta";
in
{
  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      core = {
        pager = deltaBin;
      };
      interactive = {
        diffFilter = "${deltaBin} --color-only";
      };
      delta = {
        navigate = true;
      };
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
    };
  };
}
