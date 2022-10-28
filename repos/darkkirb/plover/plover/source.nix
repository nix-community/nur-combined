{
  fetchFromGitHub,
  applyPatches,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  applyPatches {
    patches = [./wayland.patch];
    src = fetchFromGitHub {
      owner = "openstenoproject";
      repo = "plover";
      inherit (source) rev sha256;
    };
  }
