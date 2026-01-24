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
  version = "0.5.0-unstable-2026-01-21";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "3105b029542b212476fd9ce9d3bc7aeb07b5d3e9";
    hash = "sha256-wKHr1ROju3mkIEYG/uKqSvKDsrGMa1E66qM5K6sobT0=";
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
