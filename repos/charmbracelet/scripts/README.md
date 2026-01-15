# Scripts

## Crush module options generator

Generates Nix module options from the Crush JSON schema.

### Usage

```bash
cd scripts && go generate
```

The generator automatically fetches the version from `pkgs/crush/default.nix` and downloads the corresponding schema from GitHub.

You can also run it manually:

```bash
go run scripts/generate-crush-settings.go -output modules/crush/options/settings.nix
```

### Automatic updates

A GitHub Actions workflow runs daily at 3:00 UTC to check for schema updates and automatically opens a PR if changes are detected.
