{
  lib,
  rustPlatform,
  coreutils,
  gitMinimal,
  makeBinaryWrapper,
  writableTmpDirAsHomeHook,

  sources,
  source ? sources.git-cow,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock;

  nativeBuildInputs = [ makeBinaryWrapper ];

  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    wrapProgram $out/bin/git-cow \
      --suffix PATH : ${
        lib.makeBinPath [
          coreutils
          gitMinimal
        ]
      }
    install -Dm644 SKILL.md $out/share/git-cow/SKILL.md
  '';

  meta = {
    description = "Git worktrees that share files with a template through copy-on-write clones";
    homepage = "https://github.com/gabrielkoerich/git-cow";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "git-cow";
    platforms = lib.platforms.unix;
  };
})
