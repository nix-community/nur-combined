{
  lib,
  melpaBuild,
  fetchFromGitHub,
  magit,
  evil,
  nix-update-script,
}:

melpaBuild (finalAttrs: {
  pname = "majutsu";
  version = "0.6.0-unstable-2026-05-02";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "f33d37bd158de1217df85e5b889267c7cbd8eca9";
    hash = "sha256-km8AaLPK8jV8zA3nxTJuoLJuO9SJT9hS0MqB2J0wX+4=";
  };

  packageRequires = [
    magit
    evil
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Magit for jujutsu";
    homepage = "https://github.com/0WD0/majutsu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
})
