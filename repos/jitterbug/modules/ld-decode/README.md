# [ld-decode](https://github.com/happycube/ld-decode)
- Enable `exportVersionVariable` to export the git hash to the environment variable `__LD_DECODE_VERSION`.

>[!IMPORTANT]
>The package must be in `nixpkgs` (e.g. via `packageOverrides` or overlays) for this module to work.

## Example
```
{
  nixpkgs.config.packageOverrides = pkgs: {
    ld-decode = url.ld-decode;
  };

  programs.ld-decode = {
    enable = true;
    exportVersionVariable = true;
  }
}
```