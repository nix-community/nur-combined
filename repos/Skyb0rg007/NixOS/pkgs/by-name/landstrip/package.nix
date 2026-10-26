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
  version = "0.20.12";
  __structuredAttrs = true;
  src = fetchFromGitHub {
    owner = "landstrip";
    repo = "landstrip";
    tag = finalAttrs.version;
    hash = "sha256-jCyx5R6xIpQPVsOjFeCHPFpLbc3yMHVSY6wBENnod/E=";
  };
  sourceRoot = "${finalAttrs.src.name}/packages/landstrip";

  cargoHash = "sha256-20E+6n+dp9xloKmfhH+u4XINZmtH3z8Helv9hufLKcg=";

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
