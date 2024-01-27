# [vhs-decode](https://github.com/oyvindln/vhs-decode)
vhs-decode consists of a package and module.

The package must be in your in your `nixpkgs` via `packageOverrides` for the module to work.

Enable `exportVersionVariable` to have the environment variable `__VHS_DECODE_VERSION` set to the git hash.

## Example
```
{
  nixpkgs.config.packageOverrides = pkgs: {
    vhs-decode = url.vhs-decode;
  };

  programs.vhs-decode = {
    enable = true;
    exportVersionVariable = true;
  }
}
```