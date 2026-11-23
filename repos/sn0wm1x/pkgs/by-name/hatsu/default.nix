{
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  rustPlatform,
  sqlite,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "hatsu";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "importantimport";
    repo = "hatsu";
    rev = "refs/tags/v${version}";
    hash = "sha256-+UHisknNDRJU4YcQunszpUHLUZwLIZcKot2eN/iSVf8=";
  };

  cargoHash = "sha256-bzJn7za/GQpr4VSQ/btZiq10J4e2J978aFgdJ1tEkyQ=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sqlite ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=unstable" "--use-github-releases" ];
  };

  meta = {
    description = "Self-hosted and fully-automated ActivityPub bridge for static sites";
    homepage = "https://github.com/importantimport/hatsu";
    changelog = "https://github.com/importantimport/hatsu/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "hatsu";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = lib.platforms.linux;
  };
}
