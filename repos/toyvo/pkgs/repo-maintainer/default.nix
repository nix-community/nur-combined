{
  lib,
  bun,
  git,
  nix,
  openssh,
  zstd,
  writeShellApplication,
  ...
}:

writeShellApplication {
  name = "repo-maintainer";
  runtimeInputs = [
    bun
    git
    nix
    openssh
    zstd
  ];
  text = ''
    exec bun ${./src}/main.ts "$@"
  '';
}
// {
  meta = {
    description = "Durable Forgejo repo maintainer: polls CI, reruns infra cancels, opens fix PRs";
    homepage = "https://git.toyvo.dev/toyvo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "repo-maintainer";
    maintainers = with lib.maintainers; [ toyvo ];
  };
}
