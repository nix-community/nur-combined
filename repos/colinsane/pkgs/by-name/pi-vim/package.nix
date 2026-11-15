{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-vim";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zkpmLFWxBQYOYiS8vrs3EiNwqcRwRVfdT+3uzi+64ds=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-C5cBKvG8gNlecTuzLUa5LDBd1aeTpf5Ln0D/anTcinA=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modal vim-like editing for Pi's input prompt. Covers the high-frequency 90% command surface.";
    homepage = "https://github.com/lajarre/pi-vim";
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
})
