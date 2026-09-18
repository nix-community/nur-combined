{ pkgs }:

with pkgs.lib; {
  mkMeta = { description, license, homepage, mainProgram }: {
    inherit description homepage mainProgram;
    licenses = [ licenses.${license} ];
  };
}
