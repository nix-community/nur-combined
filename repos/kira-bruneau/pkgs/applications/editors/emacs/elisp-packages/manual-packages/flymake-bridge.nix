{
  lib,
  melpaBuild,
  fetchFromGitHub,
  lsp-bridge,
  nix-update-script,
}:

melpaBuild {
  pname = "flymake-bridge";
  version = "0-unstable-2024-10-29";

  src = fetchFromGitHub {
    owner = "liuyinz";
    repo = "flymake-bridge";
    rev = "76d6c5fd8fccbb527010bd19c9e1e88dc0def2bc";
    hash = "sha256-6qIaPkyq01t8bYS4HLvQH+ts1R1kXhffhem0hlsbu/w=";
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
