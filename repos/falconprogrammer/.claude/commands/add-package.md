You are helping add a new package to this NUR (Nix User Repository).

Ask the user for the following information if not already provided:
1. **GitHub repository URL or owner/repo** (e.g., "https://github.com/github/spec-kit" or "github/spec-kit")
2. **Package name** (what to call it in the NUR, defaults to repo name)
3. **Auto-update** (yes/no - whether to create a GitHub Actions workflow for automatic updates)

## Workflow Overview

This command uses `nix-init` to generate the initial package definition, then customizes it for this NUR.

## Step 1: Generate initial package with nix-init

First, ensure you're in the development shell:
```bash
nix develop
```

Then use nix-init to generate the package (run this interactively with the user):
```bash
cd pkgs
mkdir <package-name>
cd <package-name>
nix-init
```

Have the user follow nix-init's prompts. It will ask about:
- Repository URL
- Package type (Python, Rust, Go, etc.)
- Build system
- Dependencies
- License
- Description

nix-init will generate a `default.nix` file.

## Step 2: Verify and adjust the package definition

After nix-init generates the package:

1. **Check the package definition** at `pkgs/<package-name>/default.nix`
2. **Verify package type**:
   - If it's a Python **library** using `buildPythonPackage`: Good! This will be auto-versioned for Python 3.11/3.12/3.13
   - If it's a Python **application** using `buildPythonApplication`: Good! This will be built only for Python 3.12
   - Make sure `pythonImportsCheck` is set correctly
   - For applications, ensure `mainProgram` is set in meta

3. **Check for version-specific issues**:
   - If a package requires specific dependency versions not available in older nixpkgs, add:
     ```nix
     meta = with lib; {
       # ... other meta attributes
       broken = lib.versionOlder some-dependency.version "X.Y.Z";
     };
     ```

## Step 3: Calculate the correct hash

If nix-init used a dummy hash:
```bash
nix build .#<package-name> --no-link 2>&1 || true
```

Extract the correct hash from the error message and update the package.

## Step 4: Regenerate default.nix

Run the update script to add the package to the NUR:
```bash
./update-pkgs.py
```

This will:
- Detect if it's a Python package or application
- Add appropriate entries to `default.nix`
- For Python libraries: Create versioned entries (e.g., `python-jwt_311`, `python-jwt_312`, `python-jwt_313`)
- For Python applications: Create single entry using Python 3.12

## Step 5: Build and test

Test the package builds:
```bash
nix build .#<package-name> --no-link --print-build-logs
```

For applications, test it runs:
```bash
nix run .#<package-name> -- --help
```

For Python libraries, test all versions:
```bash
nix build .#<package-name>_311 --no-link
nix build .#<package-name>_312 --no-link
nix build .#<package-name>_313 --no-link
```

## Step 6: Add to auto-update workflow (if requested)

If the user wants auto-updates, add the package to the matrix in `.github/workflows/auto-update-packages.yml`:

Find the `matrix.package` section in `.github/workflows/auto-update-packages.yml` and add your package:

```yaml
    strategy:
      fail-fast: false
      matrix:
        package:
          - name: opencode-sst
            owner: sst
            repo: opencode
          - name: spec-kit
            owner: github
            repo: spec-kit
          # Add your new package here:
          - name: <package-name>
            owner: <github-owner>
            repo: <github-repo>
```

This centralized approach:
- ✅ Single cron job for all packages
- ✅ Parallel updates (all packages checked simultaneously)
- ✅ Easy to add new packages (just add to matrix)
- ✅ Consistent update logic for all packages
- ✅ Better resource usage

## Final steps

1. Review the generated package definition
2. Run `./update-pkgs.py` to register the package
3. Build and test the package
4. If auto-update was requested, add to `.github/workflows/auto-update-packages.yml`
5. Commit all changes:
   ```bash
   git add pkgs/<package-name>/ default.nix
   git add .github/workflows/auto-update-packages.yml  # if auto-update enabled
   git commit -m "feat: add <package-name> package"
   ```

## Tips

- Use `nix develop` to access `nix-init` and other development tools
- For Python packages, `nix-init` will automatically detect build systems and dependencies from pyproject.toml
- Check the generated `pythonImportsCheck` - it should match the actual Python module name
- For applications, ensure `mainProgram` is set in meta (nix-init usually does this)
- If a package needs specific dependency versions, use the `broken` flag to limit it to compatible nixpkgs channels
