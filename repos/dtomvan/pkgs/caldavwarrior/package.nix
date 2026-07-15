{
  lib,
  dmd,
  buildDubPackage,
  fetchFromGitLab,
  nix-update-script,
}:

buildDubPackage (finalAttrs: {
  pname = "caldavwarrior";
  version = "0.3.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    owner = "othee9Ku";
    repo = "caldavwarrior";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5ddUWgL0OsiuqoBK6ISimR5/oDj4hiqrRQ+nb7iVrcM=";
  };

  dubLock = ./dub-lock.json;

  installPhase = ''
    runHook preInstall
    install -Dm755 caldavwarrior -t $out/bin
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sync taskwarrior tasks with a caldav server";
    homepage = "https://gitlab.com/othee9Ku/caldavwarrior";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "caldavwarrior";
    inherit (dmd.meta) platforms;
  };
})
