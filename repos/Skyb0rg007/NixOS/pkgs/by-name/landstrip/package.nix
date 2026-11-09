{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  rustc,
  installShellFiles,
  versionCheckHook,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "landstrip";
  version = "0.20.26";
  __structuredAttrs = true;
  src = fetchFromGitHub {
    owner = "landstrip";
    repo = "landstrip";
    tag = finalAttrs.version;
    hash = "sha256-pEWjLWb5fS3/S0QOh/lEWFRAjyOx+gV8VnFVWm/dG7g=";
  };
  sourceRoot = "${finalAttrs.src.name}/packages/landstrip";

  cargoHash = "sha256-U9pgLxkY3FmUzXXL9IK2yO7CvX6cUvJpvT0TptkLFk4=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];
  buildInputs = [
    openssl
  ];
  nativeInstallCheckInputs = [ versionCheckHook ];

  doCheck = false; # Requires permissions
  doInstallCheck = true;

  # Don't vendor OpenSSL
  env.OPENSSL_NO_VENDOR = "1";

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
