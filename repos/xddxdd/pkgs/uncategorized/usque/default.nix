{
  buildGoModule,
  lib,
  sources,
  installShellFiles,
  versionCheckHook,
}:
buildGoModule rec {
  inherit (sources.usque) pname version src;
  vendorHash = "sha256-njkwrzw/8m4Y1l8aGxaK+JrYbKo/7pCT/ck0bbdaNbU=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Diniboy1123/usque/cmd.version=${version}"
  ];

  nativeBuildInputs = [
    installShellFiles
  ];
  postInstall = ''
    installShellCompletion --cmd usque \
      --bash <($out/bin/usque completion bash) \
      --fish <($out/bin/usque completion fish) \
      --zsh <($out/bin/usque completion zsh)
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${meta.mainProgram}";
  versionCheckProgramArg = "version";

  meta = {
    mainProgram = "usque";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Open-source reimplementation of the Cloudflare WARP client's MASQUE protocol";
    homepage = "https://github.com/Diniboy1123/usque";
    license = lib.licenses.mit;
    changelog = "https://github.com/Diniboy1123/usque/releases/tag/v${version}";
  };
}
