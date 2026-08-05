{
  git,
  lib,
  python3,
  static-nix-shell,
  zoekt,
}:
static-nix-shell.mkPython3 (finalAttrs: {
  pname = "auto-zoekt";
  srcRoot = ./.;
  pkgs = {
    inherit git;
    "python3.pkgs.mcp" = python3.pkgs.mcp;
    "auto-zoekt.zoekt" = finalAttrs.passthru.zoekt;
  };

  passthru = {
    zoekt = zoekt.overrideAttrs (prevAttrs: {
      # XXX(2026-08-01): build a more recent version than nixpkgs ships so that it works on git-cinnabar repos
      version = lib.warnIf (lib.versionOlder "0-unstable-2026-07-29" prevAttrs.version) "zoekt outdated: remove override?" "0-unstable-2026-07-29";
      src = prevAttrs.src.overrideAttrs {
        rev = "2cb19912a4073e5a9895658b7cb135ee4b35733b";
        hash = "sha256-unNxPyfnx7uzHKUnM7JbSSueUU361MueR3XiTqr7UHc=";
      };
      vendorHash = "sha256-IBlhyCkv6x+pf7/ODxoXxPU1jCQRQ5xLgTbugoyk2KE=";
    });
  };

  meta = {
    description = "Transparently-indexing code search MCP server, backed by the `zoekt` CLI";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
