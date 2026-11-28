# Updating the niri fork pin

The fork integrates upstream niri, virtual outputs, headless input isolation and
our session environment option. Keep the upstream nixpkgs build and install
hooks; do not reapply the old patch series to the fork.

To test an unpublished candidate, set `rev` to its full SHA in `default.nix`.
From this NUR checkout, override only the source with a clean Git snapshot:

```sh
export NIRI_REPO=/absolute/path/to/niri-worktree
nix build --no-link --print-out-paths --impure --expr '
  let nur = builtins.getFlake (toString ./.); in
  nur.packages.x86_64-linux.niri.overrideAttrs (old: {
    src = builtins.fetchGit {
      url = "file://${builtins.getEnv "NIRI_REPO"}";
      rev = old.env.NIRI_BUILD_COMMIT;
    };
  })'
```

When the Cargo lock changes, discover the new `cargoHash` with `lib.fakeHash`,
then rebuild with the reported actual hash. Run the headless VNC smoke test
with the resulting binary. Publish the fork commit before the NUR pin; verify
that `nix build --no-link .#niri` succeeds with the remote source. Do not use
an uncommitted source tree, a moving branch or a local path in the published
package.
