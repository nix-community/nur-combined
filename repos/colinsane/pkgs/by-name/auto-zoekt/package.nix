{
  git,
  lib,
  python3,
  static-nix-shell,
  zoekt,
}:
static-nix-shell.mkPython3 {
  pname = "auto-zoekt";
  srcRoot = ./.;
  pkgs = {
    inherit git zoekt;
    "python3.pkgs.mcp" = python3.pkgs.mcp;
  };

  meta = {
    description = "Transparently-indexing code search MCP server, backed by the `zoekt` CLI";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}