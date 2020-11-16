{ pkgs, sources }:
{
  bass = import ./bass { inherit pkgs sources; };
  fish-exa = import ./fish-exa { inherit pkgs sources; };
  fish-ssh-agent = import ./fish-ssh-agent { inherit pkgs sources; };
  fzf-fish = import ./fzf-fish { inherit pkgs sources; };
  oh-my-fish-plugin-foreign-env = import ./oh-my-fish-plugin-foreign-env { inherit pkgs sources; };
  oh-my-fish-plugin-ssh = import ./oh-my-fish-plugin-ssh { inherit pkgs sources; };
}
