{
  lib,
  buildGoModule,
  polkit,
  stdenv,
  writableTmpDirAsHomeHook,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "bw-ssh-agent-filter";
  version = "1.1.0";

  src = ./.;

  vendorHash = "sha256-I3/a72MNgWYZ574o3GvNjCHZaKVwD3o9DK8jb485UYY=";

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "-X main.pkcheckPath=${lib.getExe' polkit "pkcheck"}"
  ];

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  postInstall = ''
    install -Dm444 com.moraxyc.bw-ssh-agent-filter.policy -t $out/share/polkit-1/actions
  '';

  doInstallCheck = true;
  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-version";

  # nix-update auto -u
  passthru.updateScript = ./update.sh;

  meta = {
    description = "SSH agent proxy for filtering and reordering Bitwarden SSH keys";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "bw-ssh-agent-filter";
  };
})
