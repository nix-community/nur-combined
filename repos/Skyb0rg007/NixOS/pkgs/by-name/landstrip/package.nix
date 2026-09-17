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
  version = "0.19.2";
  src = fetchFromGitHub {
    owner = "landstrip";
    repo = "landstrip";
    tag = finalAttrs.version;
    hash = "sha256-Uioap4nccbS6m3Nqczg+a8uP17hoE+wahNv4Eajb4NA=";
  };
  sourceRoot = "${finalAttrs.src.name}/packages/landstrip";

  cargoHash = "sha256-YbYVxu7jmzskwRAYiOLSUz0FdCQ1KwdsEFPR/q3hLUI=";

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
