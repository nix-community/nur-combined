# [vhs-decode](https://github.com/oyvindln/vhs-decode)
- Enable `exportVersionVariable` to export the git hash to the environment variable `__VHS_DECODE_VERSION`.

>[!IMPORTANT]
>The package must be in `nixpkgs` (e.g. via `packageOverrides` or overlays) for this module to work.

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