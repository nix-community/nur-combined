{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "microbiome";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "dsmaugy";
    repo = "microbiome";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RUAkXKzIrIxaVeswCBkDhCnAMKlQxAYt5m9ho1nZRFs=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "Microbiome.jucer";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A delay-based audio effects plugin";
    homepage = "https://github.com/dsmaugy/microbiome";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
