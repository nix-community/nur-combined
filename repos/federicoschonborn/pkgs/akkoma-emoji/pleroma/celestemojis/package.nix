{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (_: {
  pname = "pleroma-celestemojis";
  version = "0-unstable-2019-10-12";

  src = fetchurl {
    url = "https://git.pleroma.social/pleroma/emoji-index/-/raw/63b792ffded1e679ff22979628753889c4e7782b/packs/celestemojis.zip";
    hash = "sha256-mMSsLKZvvRkFsDk8HtLDoDthpOpOPysxcNSlXlybcQs=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp celestemojis/*.{png,gif} $out

    runHook postInstall
  '';

  meta = {
    description = "A pack of edited and unedited pictures from the indie video game Celeste";
    # https://git.pleroma.social/pleroma/emoji-index/-/blob/46a20517c33efbb8bb34e335c3534d08bd049c48/index.json#L38
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
