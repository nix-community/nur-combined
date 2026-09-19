# pkgs/

One directory per package, each containing a `default.nix`. Directories without
a `default.nix` (helper scripts, notes, ...) are ignored by the tooling below.

## Adding a package

Create `pkgs/<name>/default.nix` and `git add` it. No registration is needed:
[`../default.nix`](../default.nix) scans this directory and turns every
subdirectory holding a `default.nix` into an attribute (`nix build .#<name>`).
The `git add` matters because flakes only see git-tracked files.

Then add it to the package list in the [root README](../README.md).

Mark packages that do not build as `broken = true;` in their `meta`: [`ci.nix`](../ci.nix)
skips those, so CI and the binary cache will not fail on them.

## Updating packages

### `update.sh`

```bash
./pkgs/update.sh                     # update ALL packages
./pkgs/update.sh nxapi               # update nxapi only (latest version)
./pkgs/update.sh nxapi 1.7.0         # nxapi to a specific version
./pkgs/update.sh --force nxapi       # same, even if nxapi is blacklisted
```

Prerequisites: `nix-update`, invoked through `nix run nixpkgs#nix-update` so it
does not need to be installed. (`jq`, `nix-prefetch-url` and `python3` are also
listed in the script header — `nix-update` shells out to them.)

For each package the script:

1. reads the current version (`nix eval .#<pkg>.version`, falling back to a
   `grep` on the `.nix` sources);
2. runs `nix-update`, which bumps the version and refreshes the hashes;
3. builds the package (`nix build .#<pkg> --no-link`) to check it still
   evaluates and builds;
4. optionally commits the change — only when `AUTO_COMMIT=1`.

Packages using `electron_<n>_<n>` or `nodejs_<n>` are detected automatically
and built with `NIXPKGS_ALLOW_INSECURE=1`.

A failing package does not stop the run: the loop continues and the failures
are listed in the script's final summary (exit code 1 if any).

### Report file

Set `REPORT_FILE` to also get one tab-separated row per package — status, name,
old version, new version, note — with status being `ok`, `skipped` or `failed`:

```bash
REPORT_FILE=/tmp/report.tsv ./pkgs/update.sh
```

Rows are appended, so delete the file first for a fresh report. CI reads this
file to build the run summary (see [below](#automated-updates)).

### Blacklisting a package

Drop a `.nix-update-ignore` file in the package directory to exclude it from
automatic updates:

```bash
echo "pinned: upstream 2.x breaks the TUI" > pkgs/nxapi/.nix-update-ignore
```

The package is then skipped both in bulk mode and when named explicitly. The
first non-empty line of the marker is printed as the reason, and the package is
listed separately in the summary — a skipped package is not a failure, so the
run still exits 0.

```
=== Skipped: nxapi (blacklisted via .nix-update-ignore) ===
  reason: pinned: upstream 2.x breaks the TUI
```

Use `--force` (or `-f`) to override the blacklist for a single run:

```bash
./pkgs/update.sh --force nxapi
```

The marker filename is the `SKIP_MARKER` variable at the top of `update.sh` if
you want a different name.

### Automated updates

[`.github/workflows/nix-update.yml`](../.github/workflows/nix-update.yml) runs
`./pkgs/update.sh` every 6 hours with `AUTO_COMMIT=1` and pushes the resulting
per-package commits (`<pkg>: <old> -> <new>`, or `<pkg>: update source hashes`
when the version did not change).

A blacklist marker is only effective on CI if it is committed — the job starts
from a fresh checkout, so an untracked `.nix-update-ignore` simply is not there.

The job writes the outcome of each run to the [workflow run
summary](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/add-a-job-summary):
counts of updated / already up to date / skipped / failed packages, then one
table per category (with the pinned reason for blacklisted packages and the
step that failed for broken ones), and finally the list of pushed commits.
