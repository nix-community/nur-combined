# nur-packages

My [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- **blobl_lsp** — language server for [Bloblang](https://warpstreamlabs.github.io/bento/docs/guides/bloblang/about/),
  the mapping language used by [Bento](https://warpstreamlabs.github.io/bento/).

## Usage

```console
$ nix-env -f '<nixpkgs>' -iA nur.repos.hsctech.blobl_lsp
```

or with flakes:

```nix
{
  inputs.nur.url = "github:nix-community/NUR";
  # pkgs.nur.repos.hsctech.blobl_lsp
}
```
