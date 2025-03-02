{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (_: {
  pname = "pleroma-rooms";
  version = "0-unstable-2019-08-21";

  src = fetchurl {
    url = "https://git.pleroma.social/pleroma/emoji-index/-/raw/10dfb7aaf9b2ffef4aaa10a8cc7d944974cb6bc4/packs/rooms.zip";
    hash = "sha256-slpJWsBjdJg3MZBw3GJPfYTWFiz/Y3ILupv9qoWuGkY=";
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
    description = "Floor plan symbols for your room";
    # https://git.pleroma.social/pleroma/emoji-index/-/blob/46a20517c33efbb8bb34e335c3534d08bd049c48/index.json#L30
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
