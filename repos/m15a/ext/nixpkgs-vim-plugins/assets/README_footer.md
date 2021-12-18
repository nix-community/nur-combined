
## Contribution

### How to add a new plugin

#### 1. Add a new entry to `manifest.txt`

In `manifest.txt`, an entry is specified by one of the following forms:

- `owner/repo`: a GitHub repo with default branch (typically `main` or `master`).
- `github:owner/repo`: again, a GitHub repo with default branch.
- `gitlab:owner/repo`: a GitLab repo with default branch.
- `owner/repo:branch`: a GitHub repo with a specific branch.
- `github:owner/repo:branch`: again, a GitHub repo with a specific branch.
- `gitlab:owner/repo:branch`: a GitLab repo with a specific branch.

After adding your entry, run:

```
nix run .#update-vim-plugins -- lint
```

So that entries are sorted and duplicated ones are removed.

#### 2. Update Nix expression and README

Next, run this:

```
nix run .#update-vim-plugins
```

After that, `pkgs/vim-plugins.nix` and the plugin list in `README.md` are updated.

#### 3. Override your plugin derivation in `overrides.nix`

In `overrides.nix`, you see something like

```nix
  {
    # ...

    lspactions = super.lspactions.overrideAttrs (_: {
      dependencies = with final.vimPlugins; [
        plenary-nvim
        popup-nvim
        self.astronauta-nvim
      ];
    });

    # ...
  }
```

Add your overrides here if needed.

#### 4. Create a Pull Request if you like

Anyone is welcome to add another plugin to this repo.
Feel free to create a PR with your new plugins!
In that case, make sure you commit only `manifest.txt` and `overrides.nix` if changed.
Other files will be updated by GitHub Action.

## License

[MIT](LICENSE)
