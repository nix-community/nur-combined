{
  lib,
  melpaBuild,
  fetchFromGitHub,
  lsp-bridge,
  nix-update-script,
}:

melpaBuild {
  pname = "flymake-bridge";
  version = "0-unstable-2025-01-23";

  src = fetchFromGitHub {
    owner = "liuyinz";
    repo = "flymake-bridge";
    rev = "e387f43230da9c214be297b0e9393323a67e4b73";
    hash = "sha256-iq+yMNAEppWYFc+fG25Hi1v6+qHKxv/UXRBI8NM5Mto=";
  };

  packageRequires = [ lsp-bridge ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "lsp-bridge Flymake backend for server diagnostics";
    homepage = "https://github.com/liuyinz/flymake-bridge";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
}
