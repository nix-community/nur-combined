{ pkgs, sources }:
with pkgs;
with sources;
{
  name = "fish-ssh-agent";
  src = fetchFromGitHub {
    inherit (fish-ssh-agent) owner repo rev sha256;
  };
}
