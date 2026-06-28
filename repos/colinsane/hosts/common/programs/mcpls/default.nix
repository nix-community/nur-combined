# exposes LSPs over MCP, for agent harnesses like Pi
# <https://github.com/bug-ops/mcpls>
{ lib, pkgs, ... }:
let
  configFile = (pkgs.formats.toml {}).generate "mcpls.toml" {
    workspace = {
      roots = [];  # auto-detect from cwd
      position_encodings = [ "utf-8" "utf-16" ];
    };
    lsp_servers = [
      {
        language_id = "nix";
        command = lib.getExe pkgs.nixd;
        args = [];
        file_patterns = [ "**/*.nix" ];
      }
      {
        language_id = "rust";
        command = lib.getExe pkgs.rust-analyzer;
        args = [];
        file_patterns = [ "**/*.rs" ];
      }
      {
        language_id = "python";
        command = "${lib.getExe' pkgs.pyright "pyright-langserver"}";
        args = [ "--stdio" ];
        file_patterns = [ "**/*.py" "**/*.pyw" "**/*.pyi" ];
      }
      {
        language_id = "typescript";
        command = lib.getExe pkgs.typescript-language-server;
        args = [ "--stdio" ];
        file_patterns = [ "**/*.ts" "**/*.mts" "**/*.cts" "**/*.tsx" ];
      }
      {
        language_id = "javascript";
        command = lib.getExe pkgs.typescript-language-server;
        args = [ "--stdio" ];
        file_patterns = [ "**/*.js" "**/*.mjs" "**/*.cjs" "**/*.jsx" ];
      }
      {
        language_id = "lua";
        command = lib.getExe pkgs.lua-language-server;
        args = [];
        file_patterns = [ "**/*.lua" ];
      }
    ];
  };
in
{
  sane.programs.mcpls = {
    suggestedPrograms = [
      "nixd"
      "rust-analyzer"
      "pyright"
      "typescript-language-server"
      "lua-language-server"
    ];
    # sandbox.net = "clearnet";  # language servers may fetch dependencies/indexes
    sandbox.whitelistPwd = true;

    fs.".config/mcpls/mcpls.toml".symlink.target = configFile;
  };
}
