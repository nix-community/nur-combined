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
  version = "0.3.0-unstable-2025-12-10";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "c6f8fa784b30783ccdccb34ed1fcb192ef31a385";
    hash = "sha256-1FTGDtGtQiNxmQjVmADkTHytlSNTieMTUw8n1zyTYr0=";
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
