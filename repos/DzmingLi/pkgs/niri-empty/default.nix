{
  lib,
  fetchFromCodeberg,
  rustPlatform,
  runtimeShell,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri-empty";
  version = "3.0.1-unstable-2026-05-18";

  src = fetchFromCodeberg {
    owner = "lunahd";
    repo = "niri-empty";
    rev = "daff79e830aed66e63e7e3aeba3e0551a077791b";
    hash = "sha256-iwr0lBihjdmvJfhyrJI5MW3Xeytya/Rit+vkUybh94A=";
  };

  cargoHash = "sha256-L5Upv90jChY9j7FoQQj3VsUbnGWJVRV9iY9RYYSPEik=";

  strictDeps = true;

  postPatch = ''
    substituteInPlace src/main.rs \
      --replace-fail 'Command::new("sh")' 'Command::new("${runtimeShell}")'
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    ${placeholder "out"}/bin/niri-empty --help \
      | grep -F "Execute a shell command when focusing an empty workspace in niri" \
      >/dev/null

    runHook postInstallCheck
  '';

  meta = {
    description = "Execute a shell command when focusing an empty workspace in niri";
    homepage = "https://codeberg.org/lunahd/niri-empty";
    license = lib.licenses.mit;
    mainProgram = "niri-empty";
    platforms = lib.platforms.linux;
  };
})
