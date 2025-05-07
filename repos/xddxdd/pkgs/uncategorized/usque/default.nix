{
  lib,
  buildGoModule,
  # fetchFromGitHub,
  stdenv,
  nix-update-script,
  buildPackages,
  sources,
  installShellFiles,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  inherit (sources.usque) pname version src;
  vendorHash = "sha256-dnM4jJVGo9UR47dFc8eEC0ntFopBWco9qS4qKEScXmc=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Diniboy1123/usque/cmd.version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [
    installShellFiles
  ];
  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd usque \
        --bash <(${emulator} $out/bin/usque completion bash) \
        --fish <(${emulator} $out/bin/usque completion fish) \
        --zsh <(${emulator} $out/bin/usque completion zsh)
    ''
  );
  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  versionCheckProgramArg = "version";

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "usque";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Open-source reimplementation of the Cloudflare WARP client's MASQUE protocol";
    homepage = "https://github.com/Diniboy1123/usque";
    license = lib.licenses.mit;
    changelog = "https://github.com/Diniboy1123/usque/releases/tag/v${finalAttrs.version}";
  };
})
