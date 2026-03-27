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
  version = "0.6.0-unstable-2026-03-13";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "c329beb4a959efe2ad07007dc9c983a0dfbf34a3";
    hash = "sha256-0XE/+4feNnu2Ip2bQLR++kl5rD/rkdlA2B3g3ZuQEfg=";
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
