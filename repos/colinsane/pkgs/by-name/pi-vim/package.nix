{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-vim";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DGOWfuLhozXLsWPF3jdGdlmMKGyWZYfzF2V0SsXcDV0=";
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-lWt8VSm/PqasMbFUZ2FmFj3Vyt2MAvTcyzOjUulNn68=";

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-vim/* $out
    rmdir $out/lib/node_modules/pi-vim
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "Modal vim-like editing for Pi's input prompt. Covers the high-frequency 90% command surface.";
    homepage = "https://github.com/lajarre/pi-vim";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
