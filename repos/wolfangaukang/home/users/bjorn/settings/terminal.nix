{ pkgs }:

{
  font = {
    name = "MesloLGS NF";
    package = pkgs.meslo-lgs-nf;
    size = 9;
  };
  shellAliases = {
    ".." = "cd ..";
    "ed" = "$EDITOR";
  };
}
