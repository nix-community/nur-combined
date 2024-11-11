{
  writeShellApplication,
  imagemagick,
  fetchFromGitHub,
  stdenv,
}: let
  explode = stdenv.mkDerivation {
    pname = "explode.gif";
    version = "0-unstable-2024-07-11";
    src = fetchFromGitHub {
      owner = "mothdotmonster";
      repo = "explode.moth.monster";
      rev = "6858000a9075aa04717cafb6aa6b0b4f7897e830";
      hash = "sha256-KwPfVNpFp49UC/XfhizfitXvEg7gaeow7YwXydx5D4Q=";
    };

    nativeBuildInputs = [imagemagick];

    buildPhase = ''
      magick res/*.gif explode.gif
    '';
    installPhase = ''
      mkdir -p $out
      cp explode.gif $out/
    '';
  };
in
  writeShellApplication {
    name = "explode";
    text = builtins.readFile ./script.sh;
    runtimeEnv = {inherit explode;};
    runtimeInputs = [imagemagick];
  }
