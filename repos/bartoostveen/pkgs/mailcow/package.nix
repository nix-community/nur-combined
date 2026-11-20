{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mailcow";
  version = "2026-11b";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mailcow";
    repo = "mailcow-dockerized";
    tag = finalAttrs.version;
    hash = "sha256-KbDJnmfpNyJkQVqLm8Ub8ZQvTYRuBxoimCCN48rRPDA=";
  };

  installPhase = ''
    mkdir -p $out/share/mailcow
    cp -r data/web $out/share/mailcow/
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The mailserver suite with the 'moo'";
    homepage = "https://github.com/mailcow/mailcow-dockerized";
    changelog = "https://github.com/mailcow/mailcow-dockerized/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "mailcow";
    platforms = lib.platforms.all;
  };
})
