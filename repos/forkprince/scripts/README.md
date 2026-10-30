# Scripts

Where we put custom scripts needed to help maintain this NUR repo.

## Updater

Updates a package's `version.json` from upstream.

```sh
bun scripts/index.js pkgs/<name>/version.json
```

`-f` / `--force` ignores the current version and `locked`.

```json
{
  "source": {
    "type": "github-release",
    "repo": "owner/repo"
  },
  "asset": {
    "file": "App-{version}.dmg"
  },
  "version": "1.2.3"
}
```

`source.type` is one of `github-repo`, `github-release`, `forgejo-release`, `gitlab-release`, `api`, `redirect`.

Platforms and variants get their own hashes. Variants share the top-level `version`; platforms share it unless an entry defines its own.

Set `locked: true` to skip a package or `force: true` to always update it.

## README updater

Regenerates the package table in `README.md`.

```sh
bun scripts/readme.js          # update
bun scripts/readme.js --check  # exit 1 if stale
```
