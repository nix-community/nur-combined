{ pkgs, sources }:
{
  oh-my-fish-plugin-foreign-env = import ./oh-my-fish-plugin-foreign-env { inherit pkgs sources; };
  oh-my-fish-plugin-ssh = import ./oh-my-fish-plugin-ssh { inherit pkgs sources; };
}
