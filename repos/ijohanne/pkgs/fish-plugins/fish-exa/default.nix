{ pkgs, sources }:
with pkgs;
with sources;
{
  name = "fish-exa";
  src = fetchFromGitHub {
    inherit (fish-exa) owner repo rev sha256;
  };
}
