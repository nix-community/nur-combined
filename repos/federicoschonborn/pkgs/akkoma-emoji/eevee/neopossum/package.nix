{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eevee-neopossum";
  version = "0.5";

  src = fetchzip {
    url = "https://skunks.gay/download/neopossum-256px_v${finalAttrs.version}.zip";
    hash = "sha256-md1CKmw+UroixUdW+AceXdGQmzcwT+KkZt3AnYx/xFw=";
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
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
