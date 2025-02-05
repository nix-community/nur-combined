{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (_: {
  pname = "pleroma-buns";
  version = "0-unstable-2019-11-05";

  src = fetchurl {
    url = "https://git.pleroma.social/pleroma/emoji-index/-/raw/41d7cf80b21082988837b6147d32d6a1910b0ae9/packs/buns.zip";
    hash = "sha256-05jTsGrNTuyI7fudHJ6qBe/fiO0nCPihuSF/MnTV3r4=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp *.png $out

    runHook postInstall
  '';

  meta = {
    description = "A pack of buns";
    # https://git.pleroma.social/pleroma/emoji-index/-/blob/46a20517c33efbb8bb34e335c3534d08bd049c48/index.json#L46
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
