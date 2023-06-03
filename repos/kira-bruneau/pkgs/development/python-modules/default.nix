pkgs: final: prev:

with final;

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  debugpy = callPackage ./debugpy { };

  huggingface-hub = callPackage ./huggingface-hub { };

  pygls = callPackage ./pygls { };

  pytest-datadir = callPackage ./pytest-datadir { };

  vdf = callPackage ./vdf { };
}
