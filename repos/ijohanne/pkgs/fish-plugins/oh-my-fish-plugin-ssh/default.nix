{ pkgs, sources }:
with pkgs;
with sources;
{
  name = "oh-my-fish-plugin-ssh";
  src = fetchFromGitHub {
    inherit (oh-my-fish-plugin-ssh) owner repo rev sha256;
  };
}
