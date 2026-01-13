# Packaging Rust Applications with Nix

See `resource/codex/package.nix` for an example.

## Updating an Existing Rust Package

Besides the general update steps, also update the `cargoHash`:

```bash
# Set cargoHash = ""; then run nix build
# Nix will fail and show: "got: sha256-XXXXX"
```

If `Cargo.toml` dependencies changed, the build will automatically fetch new dependencies after you update the `cargoHash`.
