{
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "helix-file-watcher";
  version = "0.1.0";

  src = ../helix-file-watcher;

  cargoHash = "sha256-BJ+YqAXDsiADmwUC1Ohioa5f7PTH14/RoamN+5RWT9M=";

  installPhase = ''
    runHook preInstall

    install -Dm755 "$(find target -name libhelix_file_watcher.so -type f -print -quit)" \
      $out/lib/libhelix_file_watcher.so
    install -Dm644 cog.scm $out/share/steel/cogs/helix-file-watcher/cog.scm
    install -Dm644 file-watcher.scm $out/share/steel/cogs/helix-file-watcher/file-watcher.scm
    install -Dm644 helix-file-watcher.scm $out/share/steel/cogs/helix-file-watcher/helix-file-watcher.scm

    runHook postInstall
  '';

  meta = {
    description = "Automatic file refresh for Helix Steel";
    homepage = "https://github.com/mtul0729/helix-file-watcher";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
