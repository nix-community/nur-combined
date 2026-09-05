# peazip-rar

PeaZip with Nixpkgs' `_7zz-rar` backend. It can extract RAR archives, including RAR5 archives using newer compression methods. The package also provides `7z`, pointing at that backend, so PeaZip can find it when launched from a desktop entry.

The package requires enabling unfree packages because the RAR decoder is distributed under the unRAR licence. It does not add RAR archive creation support.

```nix
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.nur.repos.so1ve.peazip-rar
  ];
}
```
