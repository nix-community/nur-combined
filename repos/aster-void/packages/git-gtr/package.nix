{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  git,
  coreutils,
  gnused,
  gnugrep,
  findutils,
  gawk,
}:
stdenvNoCC.mkDerivation {
  pname = "git-gtr";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "coderabbitai";
    repo = "git-worktree-runner";
    rev = "v2.0.0";
    hash = "sha256-TPd+5WtEZsR6x4/OPVkrIpW7SSDJpbZbvjYR8rzdZAs=";
  };

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/git-gtr $out/bin

    cp -r bin lib adapters completions templates $out/share/git-gtr/

    makeWrapper $out/share/git-gtr/bin/git-gtr $out/bin/git-gtr \
      --prefix PATH : ${lib.makeBinPath [git coreutils gnused gnugrep findutils gawk]}

    runHook postInstall
  '';

  meta = {
    description = "A portable, cross-platform CLI for managing git worktrees with ease";
    homepage = "https://github.com/coderabbitai/git-worktree-runner";
    license = lib.licenses.asl20;
    maintainers = [];
    platforms = lib.platforms.unix;
    mainProgram = "git-gtr";
  };
}
