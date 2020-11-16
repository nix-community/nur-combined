{ pkgs, sources }:
with pkgs;
with sources;
{
  name = "oh-my-fish-plugin-foreign-env";
  src = fetchFromGitHub {
    inherit (oh-my-fish-plugin-foreign-env) owner repo rev sha256;
  };
}
