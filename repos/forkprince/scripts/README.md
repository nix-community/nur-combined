# Scripts

## `index.js`

Updates a package's `version.json` from its upstream source.

```sh
bun scripts/index.js pkgs/<name>/version.json
```

Options: `-f`/`--force` (update even if locked or current), `-h`/`--help`.

Example `version.json`:

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

`source.type`: `github-repo`, `github-release`, `forgejo-release`, `gitlab-release`, `api`, `redirect`.

Hashes under `platforms` or `variants` are updated separately.

Set `"locked": true` to skip a package or `"force": true` to always update it.

## `readme.js`

Regenerates the package table in `README.md`.

```sh
bun scripts/readme.js          # update
bun scripts/readme.js --check  # exit 1 if stale
```
