{pkgs ? import <nixpkgs> {}}: {
  cargo-compete = import ./packages/cargo-compete {inherit pkgs;};
  fcitx5-hazkey = import ./packages/fcitx5-hazkey {inherit pkgs;};
  fcitx5-hazkey-git = import ./packages/fcitx5-hazkey-git {inherit pkgs;};
  chrome-devtools-mcp = import ./packages/chrome-devtools-mcp {inherit pkgs;};
  bibata-cursors-translucent = import ./packages/bibata-cursors-translucent {inherit pkgs;};
  ccusage = import ./packages/ccusage {inherit pkgs;};
  ccusage-codex = import ./packages/ccusage-codex {inherit pkgs;};
  ccusage-mcp = import ./packages/ccusage-mcp {inherit pkgs;};
  claude-code-usage-monitor = import ./packages/claude-code-usage-monitor {inherit pkgs;};
  helix-gj1118-bin = import ./packages/helix-gj1118-bin {inherit pkgs;};

  modules = {
    hazkey = ./modules/nixos/hazkey;
    hazkey-git = ./modules/nixos/hazkey-git;
  };
}
