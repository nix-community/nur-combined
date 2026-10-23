# nur-packages

My [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- **blobl_lsp** — language server for [Bloblang](https://warpstreamlabs.github.io/bento/docs/guides/bloblang/about/),
  the mapping language used by [Bento](https://warpstreamlabs.github.io/bento/).
- **tree-sitter-bloblang** — tree-sitter grammar for Bloblang.
- **helix-blobl** — [Helix](https://helix-editor.com) fork with Bloblang
  grammar and language-server support. The `helix-blobl` overlay also
  replaces `pkgs.helix` with it.

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
