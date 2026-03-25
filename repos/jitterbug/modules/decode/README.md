# decode module
- Enable `exportVersionVariable` to export the git hash to the environment variables `__DECODE_VERSION` and `__DECODE_TOOLS_VERSION`.

>[!IMPORTANT]
>The package must be in `nixpkgs` (e.g. via `packageOverrides` or overlays) for this module to work.

## Example
```
{
  nixpkgs.config.packageOverrides = pkgs: {
    decode = url.decode;
  };

  programs.decode = {
    enable = true;
    exportVersionVariable = true;
  }
}
```