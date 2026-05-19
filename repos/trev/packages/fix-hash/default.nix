{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

buildRustPackage (finalAttrs: {
  pname = "fix-hash";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nix-fix-hash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u/oPIy8Cgbq0wIBkHKjXdfVZXKELxgAp9LnmqPUjmCE=";
  };

  cargoHash = "sha256-t3XvJvjeYw+i/V5zDd3FgZ92pyZw8u4lbeZ6I0vH2/I=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    mainProgram = "fix-hash";
    description = "Nix hash fixer";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://github.com/spotdemo4/nix-fix-hash";
    changelog = "https://github.com/spotdemo4/nix-fix-hash/releases/tag/v${finalAttrs.version}";
  };
})
