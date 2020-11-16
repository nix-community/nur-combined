{ pkgs, sources }:
with pkgs;
with sources;
{
  name = "fzf-fish";
  src = fetchFromGitHub {
    inherit (fzf-fish) owner repo rev sha256;
  };
}
