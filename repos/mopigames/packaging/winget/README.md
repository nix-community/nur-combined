# winget package: `MopigamesYT.MlosHostUtils`

```powershell
winget install MopigamesYT.MlosHostUtils
```

The three `.yaml` files here are templates, not manifests: `__VERSION__`,
`__TAG__`, `__RELEASE_DATE__` and the two hashes are filled in per release by
`render.sh`, from the binaries that were actually uploaded. Nothing is
hand-edited for a release, and no hash is ever written down by hand.

```sh
./render.sh v2026.08.14 ../../host-utils/dist manifests
```

writes `manifests/m/MopigamesYT/MlosHostUtils/2026.08.14/`, which is the
layout [microsoft/winget-pkgs][pkgs] expects.

The `winget` job in `.github/workflows/host-utils.yml` runs this on every
`v*` tag and submits the result with `wingetcreate`.

[pkgs]: https://github.com/microsoft/winget-pkgs

## What the package does and does not do

It is a `portable` package: what we ship is one static binary, so there is no
installer to run. winget unpacks it and drops a shim called
`mlos-host-utils` into its Links directory, which is already on PATH — that
is the whole install.

Setting up USB passthrough is a separate, elevated step, because winget
knows nothing about USB/IP drivers, boot tasks or firewall rules:

```powershell
mlos-host-utils install
```

`InstallationNotes` in the locale manifest says so, and winget prints it
after installing. `winget uninstall` removes the binary but not the agent —
run `mlos-host-utils uninstall` first if you want it gone properly.

## Releasing

1. Tag: `git tag v2026.08.14 && git push --tags`.
2. The `build` job builds with the version taken from the tag and attaches
   the binaries to the release.
3. The `winget` job renders these templates against those exact files and
   opens a pull request against winget-pkgs.

That last step needs a `WINGET_TOKEN` repository secret: a classic personal
access token with `public_repo`, belonging to the account whose fork of
winget-pkgs the PR comes from. `github.token` cannot do it — it has no
rights in anyone else's repository. Without the secret the job still renders
and attaches the manifests to the run, so a release is never blocked on it;
they can be submitted by hand afterwards.

The first submission is the slow one: winget-pkgs runs automated validation
and then a human reviews new packages. Later versions of an existing package
usually merge automatically.
