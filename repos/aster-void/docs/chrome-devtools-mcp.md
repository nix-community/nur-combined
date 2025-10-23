# Chrome Devtools MCP

Chrome devtools mcp, wrapped with bubblewrap s.t. it doesn't require chrome to be installed at `/opt/google/chrome/chrome`.

## Usage

```sh
# doesn't require chrome to be installed to system
nix run github:aster-void/nix-repository#chrome-devtools-mcp
```

```nix
# chromium can be overridden to use another package
{ pkgs, inputs, ... }: let
  chrome-devtools-mcp = inputs.nix-repository.packages.${pkgs.system}.chrome-devtools-mcp.override {
    chromium = pkgs.ungoogled-chromium;
  };
in {
  home.packages = [
    chrome-devtools-mcp
  ];
}
```
