{ pkgs }:
{
  plugins = import ./plugins { inherit pkgs; };
}
