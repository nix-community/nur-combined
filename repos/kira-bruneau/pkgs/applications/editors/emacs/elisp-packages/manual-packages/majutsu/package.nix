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
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pdumBo9AwfpIZPolcFPGCIzTlNdH1mkagl6CcMcHBK0=";
  };

  packageRequires = [
    magit
    evil
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Magit for jujutsu";
    homepage = "https://github.com/0WD0/majutsu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
})
