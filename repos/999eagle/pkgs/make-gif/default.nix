{
  writeShellApplication,
  fetchurl,
  fetchFromGitHub,
  imagemagick,
  oxipng,
  stdenv,
  bc,
}: let
  explode = stdenv.mkDerivation {
    pname = "explode";
    version = "0-unstable-2024-07-11";
    src = fetchFromGitHub {
      owner = "mothdotmonster";
      repo = "explode.moth.monster";
      rev = "6858000a9075aa04717cafb6aa6b0b4f7897e830";
      hash = "sha256-KwPfVNpFp49UC/XfhizfitXvEg7gaeow7YwXydx5D4Q=";
    };

    nativeBuildInputs = [imagemagick oxipng];

    buildPhase = ''
      mkdir -p $out

      for gif in res/*.gif; do
        magick "$gif" "''${gif%%.*}.png"
        oxipng -o max --strip all -a -i 0 "''${gif%%.*}.png"
        cp "''${gif%%.*}.png" $out/
      done
    '';
  };
  pat = fetchurl {
    url = "https://benisland.neocities.org/petpet/img/sprite.png";
    hash = "sha256-/t72s3IFI2KX6NpauGtu6dZ9ySSUyDHBQKatHMkg/fI=";
  };
in
  writeShellApplication {
    name = "make-gif";
    text = builtins.readFile ./script.sh;
    runtimeEnv = {inherit explode pat;};
    runtimeInputs = [imagemagick bc];
    derivationArgs.passthru = {inherit explode pat;};
  }
