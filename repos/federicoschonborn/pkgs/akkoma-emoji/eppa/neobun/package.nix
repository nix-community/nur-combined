{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "eppa-neobun";
  version = "0-unstable-2024-05-02";

  src = fetchzip {
    url = "https://hofnarretje.eu/assets/emoji/neobun.zip";
    hash = "sha256-TCzMVu04zWtLyaOmN28Pp3v5V6k1/5QqGm5Gw/tTntg=";
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "A set of emojis featuring a bun";
    homepage = "https://mooi.moe/emoji.html";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
