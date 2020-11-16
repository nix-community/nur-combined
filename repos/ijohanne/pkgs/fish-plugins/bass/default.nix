{ pkgs, sources }:
with pkgs;
with sources;
{
  name = "bass";
  src = fetchFromGitHub {
    inherit (bass) owner repo rev sha256;
  };
}
