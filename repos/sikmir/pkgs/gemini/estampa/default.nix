{
  lib,
  rustPlatform,
  fetchFromSourcehut,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "estampa";
  version = "0.1.3";

  src = fetchFromSourcehut {
    owner = "~nixgoat";
    repo = "estampa";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uBoYJ2HI55cS5HUQm7PMaVO+NKHQKZ9HtG06u/5f+vk=";
  };

  cargoHash = "sha256-c9Y6PMvIty7dzVggMIQuz1iczvga6IILEyPR/REpFS8=";

  nativeCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Minimalist server for the Misfin protocol";
    homepage = "https://git.sr.ht/~nixgoat/estampa";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "estampa";
  };
})
