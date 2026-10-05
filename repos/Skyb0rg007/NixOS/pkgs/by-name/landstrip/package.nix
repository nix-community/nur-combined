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
  version = "0.19.7";
  src = fetchFromGitHub {
    owner = "landstrip";
    repo = "landstrip";
    tag = finalAttrs.version;
    hash = "sha256-jgFcZUOV+0g/tsfeGF0jc9WjcEq6Kn7XInsnvPhBW/w=";
  };
  sourceRoot = "${finalAttrs.src.name}/packages/landstrip";

  cargoHash = "sha256-X3O6LxItK/jdTfqzMGmOXkfWEAn6zIKKu5ojoH2zmDY=";

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
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin ++ lib.platforms.windows;
  };
})
