{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-vim";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VorcGMt3H4hGnbGTGUgTmJuXRK2ud+3ozT4glGX29Do=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-FyyGcyo2cIDhV3MQCeB353Knf75HAh/Z54VekEF/H/c=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modal vim-like editing for Pi's input prompt. Covers the high-frequency 90% command surface.";
    homepage = "https://github.com/lajarre/pi-vim";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
