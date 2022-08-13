
## Contribution

### How to add a new plugin

#### 1. Add a new entry to `manifest.txt`

All Nix derivations of plugins found in `pkgs/vim-plugins.nix` are generated
from `manifest.txt`, in which each line corresponds to each plugin.
An entry is specified by

```bnf
<entry> ::= [ <repo-type>  ":" ] <repo-full-name> [ ":"  [ <git-ref> ] [ ":" <attr-name> ] ]

<repo-type> ::= "github" | "gitlab" | "sourcehut"

<repo-full-name> ::= <owner-name> "/" <repo-name>
```

- If `<repo-type>` is omitted, it defaults to GitHub.
  Only GitHub, GitLab, and Sourcehut are supported.
- `<git-ref>` can be either branch name or commit hash. If omitted,
  the latest commit hash in the default branch will be used.
- Attribute name of a plugin (`pkgs.vimExtraPlugins.${attr-name}`) is
  automatically determined from `<repo-name>` by default.
  If `<attr-name>` is set in an entry, it will replace the default name.

**Examples:**

- `foo/bar`: a GitHub repo `bar` of owner `foo`, using default branch.
- `gitlab:foo/bar`:  a GitLab repo, using default branch.
- `foo/bar:dev`: a GitHub repo, using `dev` branch.
- `foo/bar:97be0965f9a0944629ba67e5fd0b05b898d34e61`: a GitHub repo,
  pinned to a commit `97be0965f9a0944629ba67e5fd0b05b898d34e61`.
- `foo/bar::baz`: a GitHub repo, using default branch, renamed to `baz`.

After adding your entry, run:

```
nix run .#update-vim-plugins -- lint
```

So that entries are checked and formatted.

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

#### 4. Create a Pull Request

Anyone is welcome to add another plugin to this repo.
Feel free to create a PR with your new plugins!
In that case, make sure you commit
`manifest.txt`, `pkgs/vim-plugins.nix`, and optionally `overrides.nix` if changed.
`README.md` will be updated by GitHub Action so it is not mandatory.

## License

[MIT](LICENSE)
