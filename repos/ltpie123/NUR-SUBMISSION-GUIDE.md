# NUR Submission Guide for lazymake

This guide walks through submitting the lazymake package to the Nix User Repository (NUR).

## ✅ Package Status

- **Package Name:** lazymake
- **Version:** 0.2.0
- **License:** MIT
- **Build Status:** ✅ Successfully builds
- **Test Status:** ✅ Binary executes correctly
- **Location:** `/home/hi/Random/projects/nur-packages`

## 📋 Pre-Submission Checklist

All items completed:

- [x] Package builds successfully with `nix-build -A lazymake`
- [x] Package follows Nixpkgs conventions
- [x] Proper metadata included (description, license, homepage, changelog)
- [x] mainProgram set for `nix run` support
- [x] Clean package.nix with no unnecessary dependencies
- [x] Uses SRI hash format for source
- [x] Go vendorHash correctly set
- [x] NUR repository structure created
- [x] README.md with package documentation
- [x] flake.nix for modern Nix users
- [x] .gitignore to exclude build artifacts

## 🚀 Submission Steps

### 1. Initialize Git Repository

```bash
cd /home/hi/Random/projects/nur-packages
git init
git add .
git commit -m "Initial commit: Add lazymake package"
```

### 2. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `nur-packages` (or your preferred name)
3. Description: "My Nix User Repository packages"
4. Make it **public** (required for NUR)
5. Do NOT initialize with README (we already have one)
6. Click "Create repository"

### 3. Push to GitHub

```bash
# Replace YOUR-USERNAME with your GitHub username
git remote add origin https://github.com/YOUR-USERNAME/nur-packages.git
git branch -M main
git push -u origin main
```

### 4. Submit to NUR

1. Fork https://github.com/nix-community/NUR
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/NUR.git
   cd NUR
   ```

3. Edit `repos.json` and add your repository:
   ```json
   {
     "repos": {
       "YOUR-USERNAME": {
         "url": "https://github.com/YOUR-USERNAME/nur-packages"
       }
     }
   }
   ```

4. Commit and push:
   ```bash
   git add repos.json
   git commit -m "Add YOUR-USERNAME repository"
   git push
   ```

5. Create a Pull Request on the NUR repository

### 5. Wait for CI and Review

- NUR CI will automatically test your repository
- It checks that all packages build successfully
- Maintainers will review and merge if everything passes
- Usually takes 1-3 days

## 📦 Using Your Package

### Before NUR Acceptance (Testing)

Users can test your package directly from GitHub:

```bash
# With nix-env
nix-env -f https://github.com/YOUR-USERNAME/nur-packages/archive/main.tar.gz -iA lazymake

# With nix build (flakes)
nix build github:YOUR-USERNAME/nur-packages#lazymake
```

### After NUR Acceptance

Once merged into NUR, users can install via:

```bash
# With nix-env
nix-env -iA nur.repos.YOUR-USERNAME.lazymake

# With nix-shell
nix-shell -p nur.repos.YOUR-USERNAME.lazymake

# In configuration.nix (NixOS)
environment.systemPackages = with pkgs; [
  nur.repos.YOUR-USERNAME.lazymake
];
```

## 🔧 Maintenance

### Updating the Package

When a new version of lazymake is released:

1. Update version in `pkgs/lazymake/default.nix`:
   ```nix
   version = "0.3.0";  # New version
   ```

2. Update the source hash (set to placeholder first):
   ```nix
   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
   ```

3. Build to get correct hash:
   ```bash
   nix-build -A lazymake 2>&1 | grep "got:"
   ```

4. Update with correct hash and set vendorHash to placeholder:
   ```nix
   vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
   ```

5. Build again to get correct vendorHash:
   ```bash
   nix-build -A lazymake 2>&1 | grep "got:"
   ```

6. Update vendorHash and verify build succeeds:
   ```bash
   nix-build -A lazymake
   ./result/bin/lazymake --help
   ```

7. Commit and push:
   ```bash
   git add pkgs/lazymake/default.nix
   git commit -m "lazymake: 0.2.0 -> 0.3.0"
   git push
   ```

NUR will automatically pick up your changes within a few hours.

## 📁 Repository Structure

```
nur-packages/
├── default.nix           # Main entry point, lists all packages
├── flake.nix            # Flakes support for modern Nix
├── README.md            # Repository documentation
├── .gitignore           # Ignore build artifacts
├── lib/                 # Custom library functions (optional)
│   └── default.nix
├── modules/             # NixOS modules (optional)
│   └── default.nix
├── overlays/            # Nixpkgs overlays (optional)
│   └── default.nix
└── pkgs/                # Package definitions
    └── lazymake/
        └── default.nix  # The lazymake package
```

## 🧪 Testing Locally

### Test with nix-build
```bash
cd /home/hi/Random/projects/nur-packages
nix-build -A lazymake
./result/bin/lazymake --help
```

### Test with flakes
```bash
cd /home/hi/Random/projects/nur-packages
nix build .#lazymake
nix run .#lazymake -- --help
```

### Test all packages
```bash
nix-build
```

## ❓ Troubleshooting

### Build Fails After Update

1. Check that the version number matches the Git tag
2. Verify the source hash is correct
3. Ensure vendorHash is updated (Go dependencies change)
4. Test locally before pushing

### NUR CI Fails

1. Check the CI logs in your NUR pull request
2. Common issues:
   - Repository not public
   - Package doesn't build on all platforms
   - Invalid Nix expression syntax
3. Fix issues and force-push to trigger re-check

### Package Not Showing Up

- NUR updates every few hours
- Check https://nur.nix-community.org/repos/YOUR-USERNAME/
- Verify your commits were pushed to GitHub

## 📚 Additional Resources

- [NUR Documentation](https://github.com/nix-community/NUR)
- [NUR Search](https://nur.nix-community.org)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## 📝 Notes

- **Update Maintainers**: Add your maintainer info to `maintainers = [ ];` if you want
- **Add More Packages**: Just add new directories under `pkgs/` and reference in `default.nix`
- **License**: Your NUR repo can have any license; individual packages keep their upstream licenses
- **Binary Cache**: NUR doesn't provide binary caches; users build from source

## ✨ What's Next?

After successful NUR submission, consider:

1. **Submit to Nixpkgs**: If the package is useful to a wide audience, consider submitting to the main nixpkgs repository (located at `/home/hi/Random/projects/nixpkgs/pkgs/by-name/la/lazymake/`)

2. **Add NixOS Module**: If lazymake would benefit from system-level configuration, create a NixOS module in `modules/`

3. **Create Overlay**: For more advanced integration, consider adding an overlay in `overlays/`

4. **Keep Updated**: Watch the upstream lazymake repository for new releases

---

**Ready to submit?** Follow the steps above and your lazymake package will be available to the entire Nix community! 🎉
