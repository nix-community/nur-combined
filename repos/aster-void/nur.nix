{pkgs ? import <nixpkgs> {}}: {
  cargo-compete = import ./packages/cargo-compete {inherit pkgs;};
  chrome-devtools-mcp = import ./packages/chrome-devtools-mcp {inherit pkgs;};
  bibata-cursors-translucent = import ./packages/bibata-cursors-translucent {inherit pkgs;};
  ccusage = import ./packages/ccusage {inherit pkgs;};
  ccusage-codex = import ./packages/ccusage-codex {inherit pkgs;};
  ccusage-mcp = import ./packages/ccusage-mcp {inherit pkgs;};
  claude-code-usage-monitor = import ./packages/claude-code-usage-monitor {inherit pkgs;};
  gwq = import ./packages/gwq {inherit pkgs;};
  helix-gj1118 = import ./packages/helix-gj1118 {inherit pkgs;};
  helix-gj1118-bin = import ./packages/helix-gj1118-bin {inherit pkgs;};
  lsmcp = import ./packages/lsmcp {inherit pkgs;};
  mcp-language-server = import ./packages/mcp-language-server {inherit pkgs;};
  osgrep = import ./packages/osgrep {inherit pkgs;};
  v-analyzer = import ./packages/v-analyzer {inherit pkgs;};

  homeModules = {
    gwq = ./modules/home/gwq.nix;
    osgrep = ./modules/home/osgrep.nix;
  };
}
