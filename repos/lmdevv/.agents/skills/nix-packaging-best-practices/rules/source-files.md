---
title: Sourcing Binary Archives
impact: HIGH
impactDescription: Absolute paths and pre-extracted directories break portability
tags: source, archives, local, remote, fetchurl, paths
---

## Sourcing Binary Archives

How to reference the source archive in your Nix derivation.

## Local Archives

For development, testing, or local files:

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.2.3";

  # ✅ Correct: Relative path from the derivation file
  src = ./myapp-${version}-linux-x86_64.tar.gz;

  # Also works for other formats
  # src = ./myapp-${version}.deb;
  # src = ./myapp-${version}.rpm;
  # src = ./myapp-${version}.zip;
}
```

**Key points:**
- Use relative path with `./` prefix
- Archive should be in same directory as default.nix
- Works with any archive format (.tar.gz, .deb, .rpm, .zip)

## Remote Archives (fetchurl)

For distributed packages or flakes:

```nix
{ pkgs, fetchurl }:

pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.2.3";

  src = fetchurl {
    url = "https://example.com/releases/myapp-${version}-linux-x86_64.tar.gz";
    hash = "sha256-AAAA BBBB CCCC DDDD...";
  };
}
```

**Getting the hash:**
```bash
# Method 1: Let Nix tell you
# Use an empty hash, Nix will fail and show the correct one
hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

# Method 2: Compute manually
nix-hash --type sha256 --flat myapp-1.2.3.tar.gz

# Method 3: With prefetch (nix-prefetch-url)
nix-prefetch-url --type sha256 https://example.com/myapp.tar.gz
```

## Incorrect

```nix
# ❌ WRONG: Breaks portability
src = /home/chumeng/Downloads/myapp.tar.gz;

# ❌ WRONG: Not reproducible
src = ./myapp-extracted;

# ❌ WRONG: Still using absolute path with fetchurl
src = fetchurl {
  url = "/home/chumeng/Downloads/myapp.tar.gz";  # Not a URL!
  hash = "sha256-...";
};
```

## Correct

```nix
# ✅ Correct: Relative path
src = ./myapp.tar.gz;

# ✅ Correct: Use original archive
src = ./myapp.tar.gz;

# ✅ Correct: Use real URL or relative path
# Option 1: Real URL
src = fetchurl {
  url = "https://example.com/myapp.tar.gz";
  hash = "sha256-...";
};

# Option 2: Local file (no fetchurl)
src = ./myapp.tar.gz;
```

## Version in Filename

Always use the `${version}` variable in the filename:

## Incorrect

```nix
# ❌ Bad: Version hardcoded separately
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-1.2.2-linux-x86_64.tar.gz;  # Mismatch!
}
# Update version → must also update filename separately
```

## Correct

```nix
# ✅ Good: Single source of truth
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-${version}-linux-x86_64.tar.gz;
}
# Update version → filename automatically updates
```

See [version-management](version-management.md) for more details.
