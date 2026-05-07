---
title: Common Pitfalls and How to Avoid Them
impact: HIGH
impactDescription: These mistakes cause non-reproducible, non-portable packages
tags: mistakes, pitfalls, errors, debugging
---

## Common Pitfalls and How to Avoid Them

## Using Pre-extracted Directories

## Incorrect

```nix
# ❌ WRONG: Not reproducible, breaks on other machines
src = ./extracted-app;
```

**Why it fails:**
- Extracted directories vary by system, user, and extraction method
- Breaks when sharing with others
- Not reproducible - different people get different results
- Violates Nix's reproducibility principle

## Correct

```nix
# ✅ Correct: Source from original archive
src = ./app.tar.gz;
```

**Fix:** Always use the original archive file as source. Let Nix extract it during build.

See [essential-pattern](essential-pattern.md) for the correct pattern.

---

## Absolute Paths

## Incorrect

```nix
# ❌ WRONG: Breaks portability
src = /home/chumeng/Downloads/app.tar.gz;
```

**Why it fails:**
- Only works on your machine
- Fails for anyone else
- Breaks in flakes, NixOS configs, CI/CD
- Makes derivation non-portable

## Correct

```nix
# ✅ Correct: Relative path
src = ./app.tar.gz;
```

**Fix:** Use relative paths with `./` prefix. Place archive in same directory as default.nix.

---

## Missing autoPatchelfHook

## Incorrect

```nix
# ❌ WRONG: Can't find libraries at runtime
pkgs.stdenv.mkDerivation {
  # ...
  buildInputs = [ pkgs.gtk3 pkgs.glib ];
  # Binary will fail with "library not found" errors
}
```

## Correct

```nix
# ✅ Correct: Patch library paths automatically
pkgs.stdenv.mkDerivation {
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.gtk3 pkgs.glib ];
}
```

**Why it fails:**
- Binary expects libraries in `/usr/lib` or similar
- Nix stores libraries in unique paths like `/nix/store/...-gtk3/lib`
- autoPatchelfHook fixes the binary's rpath to point to Nix libraries

**Fix:** Always add `autoPatchelfHook` to `nativeBuildInputs` for binary packages.

---

## Libraries in Wrong Category

## Incorrect

```nix
# ❌ WRONG: Libraries are runtime dependencies, not build tools
nativeBuildInputs = with pkgs; [
  autoPatchelfHook
  gtk3    # ← Wrong! This is a runtime library
  glib    # ← Wrong!
];
```

## Correct

```nix
# ✅ Correct: Separate build tools from runtime libraries
nativeBuildInputs = with pkgs; [
  autoPatchelfHook
];

buildInputs = with pkgs; [
  gtk3    # ← Correct: Runtime library
  glib    # ← Correct: Runtime library
];
```

**Why it fails:**
- `nativeBuildInputs` are for build-time tools only
- Libraries in `nativeBuildInputs` won't be available at runtime
- Binary will still fail to find libraries

**Fix:** Put libraries in `buildInputs`, not `nativeBuildInputs`.

See [dependencies](dependencies.md) for the three dependency categories.

---

## Hardcoded Version in Filename

## Incorrect

```nix
# ❌ BAD: Version hardcoded separately from filename
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-1.2.2-linux-x86_64.tar.gz;  # Mismatch!
}
```

## Correct

```nix
# ✅ Good: Version variable used in filename
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-${version}-linux-x86_64.tar.gz;
}
```

**Why it fails:**
- Must update two places when upgrading
- Easy to forget, causing version mismatch
- Can cause subtle bugs

**Fix:** Use `${version}` variable in filename. Single source of truth.

See [version-management](version-management.md) for more details.

---

## Wrong Extractor for Format

## Incorrect

```nix
# ❌ WRONG: .zip can't be extracted with tar
pkgs.stdenv.mkDerivation {
  src = ./app-${version}.zip;
  unpackPhase = ''
    tar xf $src  # This will fail
  '';
}
```

## Correct

```nix
# ✅ Correct: Match format to extractor
pkgs.stdenv.mkDerivation {
  src = ./app-${version}.zip;
  nativeBuildInputs = [ pkgs.unzip ];
  unpackPhase = ''
    unzip $src
  '';
}
```

**Why it fails:**
- Different formats require different tools
- tar doesn't work for .zip, .deb, or .rpm
- Build fails with cryptic error messages

**Fix:** Check [archive-formats](archive-formats.md) for the correct extractor and tools.

---

## Red Flags - STOP

If you catch yourself thinking any of these, STOP and reconsider:

| Thought | Reality |
|---------|---------|
| "User already extracted it, use that directory" | NO, source from original archive |
| "Absolute path works for me locally" | Breaks for others, use relative |
| "Just add more libraries until it works" | Find actual dependencies with `ldd` |
| "Quick local test, absolute path is fine" | Bad habits stick, do it right |
| "Mixed extraction (some pre-extracted)" | Extract everything in unpackPhase |

All of these lead to non-reproducible, non-portable packages.

## Quick Reference Table

| Mistake | Symptom | Fix |
|---------|---------|-----|
| `src = ./extracted/` | Works only on your machine | `src = ./app.tar.gz` |
| `src = /home/user/app.tar.gz` | Breaks for others | `src = ./app.tar.gz` |
| Missing autoPatchelfHook | "library not found" errors | Add to nativeBuildInputs |
| Libraries in nativeBuildInputs | Still can't find libraries | Move to buildInputs |
| Hardcoded version | Version mismatch bugs | Use `src = ./app-${version}.tar.gz` |
| Wrong extractor | Build fails | Check format-specific tools |
