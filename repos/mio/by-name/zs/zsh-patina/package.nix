{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zsh-patina";
  version = "1.8.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    tag = finalAttrs.version;
    hash = "sha256-M14IeK+Nsst+6RK6ayhq37YSoFPVptNqE9blVHDI1YM=";
  };

  cargoHash = "sha256-4Meb4BDV/Um8/YMA5DkeNDcgCMS5cA8olKhOIq9coIU=";

  nativeBuildInputs = [ installShellFiles ];
  postInstall = ''
    install -Dm644 LICENSE $out/share/licenses/zsh-patina/LICENSE
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd zsh-patina --zsh <($out/bin/zsh-patina completion)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Zsh syntax highlighter";
    homepage = "https://github.com/michel-kraemer/zsh-patina";
    changelog = "https://github.com/michel-kraemer/zsh-patina/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
    mainProgram = "zsh-patina";
  };
})
