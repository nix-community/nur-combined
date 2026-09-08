{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-vim";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y8qsUKdzAM2yQyNDKWqGBHA139tDDYJlefvT+nVhGKQ=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-C9AkJhwlh4muj+AselbSpSHcYSMZWAeaS2Mon9NVvcY=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modal vim-like editing for Pi's input prompt. Covers the high-frequency 90% command surface.";
    homepage = "https://github.com/lajarre/pi-vim";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
