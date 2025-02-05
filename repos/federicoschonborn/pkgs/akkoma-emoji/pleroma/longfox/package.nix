{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (_: {
  pname = "pleroma-longfox";
  version = "0-unstable-2019-08-03";

  src = fetchurl {
    url = "https://git.pleroma.social/pleroma/emoji-index/-/raw/3b8825f1e3d4a05b624e8099bb107097f9fd2b0e/packs/longfox.zip";
    hash = "sha256-KrXyWkY6g2oJdXntCnOhkG7MBZvKXiaPwa+dLqOlrMU=";
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
    description = "Fox with infinite length";
    # https://git.pleroma.social/pleroma/emoji-index/-/blob/46a20517c33efbb8bb34e335c3534d08bd049c48/index.json#L22
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
