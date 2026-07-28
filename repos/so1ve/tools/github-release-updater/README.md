# GitHub release updater

This updater turns a GitHub release and a small package configuration into a
Nix-friendly `sources.json`. It matches release assets exactly, uses GitHub's
SHA-256 digest when available, and falls back to `nix store prefetch-file`.

```json
{
  "name": "Example",
  "repository": "owner/repository",
  "tagPrefix": "v",
  "output": "pkgs/example/sources.json",
  "systems": {
    "x86_64-linux": {
      "asset": "Example_{version}_x64.tar.gz"
    }
  }
}
```

Asset templates can use `version`, `tag`, and `system`. The resolved asset name
and its hash are written to the corresponding source entry.

Create a runnable updater in Nix:

```nix
mkUpdater = pkgs.callPackage ./tools/github-release-updater { };
updater = mkUpdater {
  name = "example";
  config = ./pkgs/example/update.json;
};
```

Run the generated command from the repository root. It supports `GITHUB_TOKEN`
or `GH_TOKEN`.
