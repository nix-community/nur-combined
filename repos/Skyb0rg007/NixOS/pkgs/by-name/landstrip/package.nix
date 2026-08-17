{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  rustc,
  installShellFiles,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "landstrip";
  version = "0.18.30";
  src = fetchFromGitHub {
    owner = "landstrip";
    repo = "landstrip";
    tag = finalAttrs.version;
    hash = "sha256-y4sca4iYVkY2PVWsdY9gH4epcAfbH2AfbvjerB67fuE=";
  };

  cargoHash = "sha256-GI09K+J8SY+3WzZMu4/lKa7k4abs8iP8SQ3AedBrl5U=";

  nativeBuildInputs = [ installShellFiles ];
  nativeInstallCheckInputs = [ versionCheckHook ];

  doCheck = false; # Requires permissions
  doInstallCheck = true;

  postInstall = ''
    installManPage ./man/man1/landstrip.1
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Run tools in OS-level sandboxes";
    homepage = "https://github.com/landstrip/landstrip";
    changelog = "https://github.com/landstrip/landstrip/releases/tag/${finalAttrs.src.tag}";
    mainProgram = "landstrip";
    maintainers = [ lib.maintainers.skyesoss ];
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin ++ lib.platforms.windows;
  };
})
