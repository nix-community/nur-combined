{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  lists = rec {
    foldmap = seed: acc: func: list:
      let
        acc' = if acc == [] then [seed] else acc;
        x = head list;
        xs = tail list;
      in if list == [] then acc
         else acc ++ (foldmap seed [(func x acc')] func xs);
  };
  mkAfterAfter = mkOrder 1600;
}
