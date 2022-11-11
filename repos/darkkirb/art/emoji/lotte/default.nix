{
  callPackage,
  stdenvNoCC,
  libjxl,
  imagemagick,
  lib,
}: let
  crushpng = callPackage ../../../lib/crushpng.nix {};
  lotte-art = callPackage ../../lotte {};
  resized = name:
    stdenvNoCC.mkDerivation {
      inherit name;
      src = lotte-art;
      nativeBuildInputs = [libjxl imagemagick];
      buildPhase = ''
        djxl $name.jxl $name.png
        convert $name.png -scale 128x128\> $name-scaled.png
      '';
      installPhase = ''
        cp $name-scaled.png $out
      '';
    };
  lnEmojiScript = name: ''
    ln -s ${crushpng {
      inherit name;
      src = resized name;
      maxsize = 40000;
    }} $out/${name}.png
  '';
  emoji = [
    "2019-10-05-dae-lotteheart"
    "2019-10-05-dae-lottehearts"
    "2019-10-05-dae-lottepet"
    "2019-11-17-workerq-lottetrash"
    "2020-01-05-dae-lotteweary"
    "2020-01-17-workerq-lotteblep"
    "2020-01-17-workerq-lottecoffee"
    "2020-01-17-workerq-lottecookie"
    "2020-01-17-workerq-lottehug"
    "2020-01-17-workerq-lottesmile"
    "2021-03-23-sammythetanuki-lottegoodsalt"
    "2021-03-26-zomlette-agender-screem-tp"
    "2021-04-21-sammythetanuki-lottecoffeemachine"
    "2021-05-03-sammythetanuki-lotteflatfuck"
    "2021-05-03-sammythetanuki-lottehug"
    "2021-05-03-sammythetanuki-lottesnuggle"
    "2021-05-03-sammythetanuki-lottetrash"
    "2021-05-04-mizuki-lotteshocked-sticker"
    "2021-05-29-sammythetanuki-lottepizza"
    "2021-07-02-sammythetanuki-lottegrab"
    "2021-07-16-sammythetanuki-lottecarostacc"
    "2021-08-03-sammythetanuki-everyonesproblem"
    "2021-08-20-mizuki-peekabu-sticker"
    "2021-09-13-sammythetanuki-plushhug"
    "2021-10-28-pulexart-me-climbTree"
    "2021-10-28-pulexart-me-dab"
    "2021-10-28-pulexart-me-eatingPopcorn"
    "2021-10-28-pulexart-me-flirt"
    "2021-10-28-pulexart-me-garbage"
    "2021-10-28-pulexart-me-heartAce"
    "2021-10-28-pulexart-me-heartAgender"
    "2021-10-28-pulexart-me-heartLGBT"
    "2021-10-28-pulexart-me-heartNonbinary"
    "2021-10-28-pulexart-me-heartNormal"
    "2021-10-28-pulexart-me-heartRaccoongender"
    "2021-10-28-pulexart-me-heartTrans"
    "2021-10-28-pulexart-me-money"
    "2021-10-28-pulexart-me-noU"
    "2021-10-28-pulexart-me-plotting"
    "2021-10-28-pulexart-me-praise"
    "2021-10-28-pulexart-me-robber"
    "2021-10-28-pulexart-me-sleepy"
    "2021-10-28-pulexart-me-sneak"
    "2021-10-28-pulexart-me-trash"
    "2021-10-28-pulexart-me-washingFood"
    "2021-12-18-sammythetanuki-lottecookies"
    "2021-12-20-sammythetanuki-lottecrimmus"
    "2022-01-08-sammythetanuki-lotteangry"
    "2022-01-08-sammythetanuki-lottepleading"
    "2022-02-20-sammythetanuki-lottehacking-notext"
    "2022-05-05-sammythetanuki-lotteass"
    "2022-06-13-sammythetanuki-lotteplushnothoughts"
    "2022-07-14-sammythetanuki-maybecringe-transparent"
    "2022-11-06-pulexart-me-heartTherian"
    "2022-11-10-mizuki-peekabu"
  ];
in
  stdenvNoCC.mkDerivation {
    name = "lotte-emoji";
    dontUnpack = true;
    buildPhase = "true";
    installPhase = ''
      mkdir $out
      ${toString (map lnEmojiScript emoji)}
    '';
    meta = {
      description = "Stickers and emoji for the fediverse";
      license = lib.licenses.cc-by-nc-sa-40;
    };
  }
