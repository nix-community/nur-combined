{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri-sidebar";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Vigintillionn";
    repo = "niri-sidebar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MYP1ZiwV9+yJhl0zpuri6NQkQHlaYZjGBhXpZEaPZyI=";
  };

  cargoHash = "sha256-zZlfwAxWE1ZZy6k7QoBOamCGigGShd89sD27vfvgR00=";

  strictDeps = true;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    ${placeholder "out"}/bin/niri-sidebar --help \
      | grep -F "A floating sidebar manager for Niri" \
      >/dev/null

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A lightweight, external sidebar manager for the Niri window manager";
    homepage = "https://github.com/Vigintillionn/niri-sidebar";
    changelog = "https://github.com/Vigintillionn/niri-sidebar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "niri-sidebar";
    platforms = lib.platforms.linux;
  };
})
