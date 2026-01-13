# Package a Python Module with Nix

Packaging a Python module (`buildPythonPackage`) involves determining the source, dependencies, and build system, typically from `pyproject.toml`. Ensure all dependencies are already packaged before referencing them.

More complex cases require special handling. Below are examples for different scenarios.

## Normal Python Module

See the simple example: `resource/tyro/package.nix`

## Customize Build System and Disable Tests

Some Python modules require additional build tools, or have tests that cannot run in the Nix sandbox. See `resource/swanboard/package.nix` for an example.

## Customize Source Root and Optional Dependencies

See `resource/agno/package.nix` for examples of:

- Using `sourceRoot` when the Python module's root differs from the project root (specify the relative path).
- Handling optional dependencies: include them in `optional-dependencies` when available, or safely omit them if not yet packaged.

## Rust-Backed Python Module

For Python packages implemented in Rust with Python bindings, use `rustPlatform` as a helper. See `resource/tantivy/package.nix` for an example.

## Relax or Remove Dependencies

When dependency requirements cannot be satisfied, investigate further:

1. **Version mismatch**: If the dependency is packaged but the version requirement is too strict, add it to `pythonRelaxDeps` to bypass version checking.
2. **Missing dependency**: If the dependency is not packaged, assess whether it's essential for your use case. If not, add it to `pythonRemoveDeps`.

See `resource/darts/package.nix` for an example.

## Updating an Existing Python Package

Besides the general update steps, also:

1. **Update dependencies**: Check `pyproject.toml` or `setup.py` for changed dependencies and update:
   - `dependencies` - Runtime dependencies
   - `build-system` - Build-time dependencies (e.g., setuptools, poetry-core)
   - `optional-dependencies` - If relevant to your use case

2. **Handle breaking changes**: New versions may:
   - Drop Python version support (update `pythonOlder` or `disabled`)
   - Change build backends (update `build-system` based on `pyproject.toml`)
   - Add new test dependencies (update `nativeCheckInputs` or `checkInputs`)
