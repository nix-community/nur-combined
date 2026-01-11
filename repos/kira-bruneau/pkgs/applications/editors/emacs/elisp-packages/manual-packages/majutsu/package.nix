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
  version = "0.4.0-unstable-2026-01-02";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "59631ffd8e063630573e06b983cf0deaabea1d0d";
    hash = "sha256-MG4AFw7uA1hFqpuHqFPW+KqfmxnYuGDJUH544yNvlLI=";
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
