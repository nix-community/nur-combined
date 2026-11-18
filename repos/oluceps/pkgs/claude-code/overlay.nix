# Patched nixpkgs claude-code.
#
# Only nixpkgs' own claude-code goes through this: a package pulled through
# `inputs.llm-agents.packages.<system>.claude-code` never sees a nixpkgs
# overlay, so wrap that one with import ./patchClaude.nix directly.
final: prev: {
  claude-code = import ./patchClaude.nix {
    drv = prev.claude-code;
    pkgs = final;
  };
}
