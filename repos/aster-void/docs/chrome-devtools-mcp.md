# Chrome Devtools MCP

## Package (`packages.chrome-devtools-mcp`)

A simple wrapper of npm:chrome-devtools-mcp

## NixOS Module (`nixosModules.chrome-devtools-mcp`)

This module, if enabled, does these:

- creates a soft symlink at `/opt/google/chrome/chrome` that points to chrome executable.
- installs `chrome-devtools-mcp` to systems PATH

### Configuration

```nix
{
  programs.chrome-devtools-mcp = {
    enable = true;
    # Optional: override the package
    package = pkgs.chrome-devtools-mcp;
    # optional: override chrome package
    chromePackage = pkgs.chromium;
    # optional: override chrome executable path (ignores `chromePackage` if this is set)
    overrideChromeExecutable = lib.getExe pkgs.chromium;
    # Optional: override the symlink target path
    chromeSymlinkPath = "/opt/google/chrome/chrome";
  };
}
```
