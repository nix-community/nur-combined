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
  version = "0.19.4";
  src = fetchFromGitHub {
    owner = "landstrip";
    repo = "landstrip";
    tag = finalAttrs.version;
    hash = "sha256-23w/Yc4JVOmM6ele8npBGJ/mxzw4Uaf6zd7QZ5wqcxo=";
  };
  sourceRoot = "${finalAttrs.src.name}/packages/landstrip";

  cargoHash = "sha256-1fVmaWsQJ7qkSnYB8OI0HKlBVmjJhPkjwW8MiJOpwns=";

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
