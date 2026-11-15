{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "kuake-cli";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "zhangjingwei";
    repo = "kuake_cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T9GHSkbin/9F1ROxReH7oIL+TvIXy7seRa3yBeogNJU=";
  };

  # Preserve protected paths across symlink chains in the Nix container.
  patches = [ ./guard-symlink-paths.patch ];

  vendorHash = "sha256-TLC+Vlyg/aplz+woGQ3fvnGZyModYsok/knl+xC92Ds=";

  subPackages = [ "cmd" ];
  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  postInstall = ''
    mv "$out/bin/cmd" "$out/bin/kuake"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Quark Cloud Drive file management CLI";
    homepage = "https://github.com/zhangjingwei/kuake_cli";
    changelog = "https://github.com/zhangjingwei/kuake_cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "kuake";
    platforms = lib.platforms.unix;
  };
})
