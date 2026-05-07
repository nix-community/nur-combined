---
title: Version Management Best Practices
impact: MEDIUM
impactDescription: Prevents version mismatch bugs and reduces update errors
tags: version, rec, filename, variables
---

## Version Management Best Practices

## Use Version Variable in Filename

Always reference the `version` variable in the source filename. This creates a single source of truth.

## Correct

```nix
# ✅ Good: Single source of truth
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-${version}-linux-x86_64.tar.gz;
}

# When you update version, the filename updates automatically
# No need to remember to change both places
```

## Incorrect

```nix
# ❌ Bad: Version hardcoded separately
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-1.2.2-linux-x86_64.tar.gz;  # Mismatch!
}

# Easy to forget to update filename when changing version
# Leads to subtle bugs and confusion
```

## Why This Matters

### Single Update Point

```nix
# Good: Change version once
version = "1.2.4";  # ← Only change this line
# src = ./myapp-${version}-linux-x86_64.tar.gz;  # Updates automatically

# Bad: Must change version in multiple places
version = "1.2.4";  # ← Change this
src = ./myapp-1.2.2-linux-x86_64.tar.gz;  # ← And this, oops forgot!
```

### Prevents Mismatch Errors

```nix
# Bad: Version mismatch leads to wrong package being built
version = "1.2.3";      # Says 1.2.3
src = ./myapp-1.2.2...  # But actually builds 1.2.2

# Result: Package claims to be 1.2.3 but contains 1.2.2 files
# Causes confusion, security issues, wrong behavior
```

### Works with fetchurl

```nix
{ pkgs, fetchurl }:

pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";

  # ✅ Version in URL
  src = fetchurl {
    url = "https://example.com/releases/myapp-${version}-linux-x86_64.tar.gz";
    hash = "sha256-...";
  };

  # When you update version, URL updates automatically
}
```

## rec Keyword

The `rec` keyword makes all attributes available to each other:

## Without rec

```nix
# Without rec: Can't reference version in src
pkgs.stdenv.mkDerivation {
  pname = "myapp";
  version = "1.2.3";
  # src = ./myapp-${version}-linux-x86_64.tar.gz;  # Error!
}
```

## With rec

```nix
# With rec: Can reference any attribute
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-${version}-linux-x86_64.tar.gz;  # Works!
}
```

## Version in Multiple Places

You can use `version` anywhere in the derivation:

```nix
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";

  src = ./myapp-${version}-linux-x86_64.tar.gz;

  # Also use in install phase
  installPhase = ''
    mkdir -p $out/share/doc
    echo "Version ${version}" > $out/share/doc/VERSION
  '';

  # Or in metadata
  meta = with pkgs.lib; {
    description = "MyApp version ${version}";
    # ...
  };
}
```

## Updating Versions

When updating to a new version:

1. Download the new archive
2. Place it in the same directory as default.nix
3. Change the version variable

## Before

```nix
version = "1.2.3";
# src = ./myapp-1.2.3-linux-x86_64.tar.gz  (implicitly)
```

## After

```nix
# Single line change
version = "1.2.4";
# src = ./myapp-1.2.4-linux-x86_64.tar.gz  (automatically)
```

If using fetchurl, you also need to update the hash:

```nix
version = "1.2.4";

src = fetchurl {
  url = "https://example.com/myapp-${version}-linux-x86_64.tar.gz";
  hash = "sha256-NEW-HASH-HERE";  # ← Update this too
};
```

See [source-files](source-files.md) for how to get fetchurl hashes.

## Multi-Part Versions

For complex version numbers:

```nix
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  # Can extract parts if needed
  majorVersion = builtins.elemAt (builtins.splitVersion version) 0;

  src = ./myapp-${version}-linux-x86_64.tar.gz;
}
```

## Real-World Example

```nix
{ pkgs, fetchurl }:

pkgs.stdenv.mkDerivation rec {
  pname = "vscode";
  version = "1.85.0";

  src = fetchurl {
    url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
    name = "VSCode-linux-x64-${version}.tar.gz";
    hash = "sha256-...";
  };

  # Version used in multiple places
  installPhase = ''
    mkdir -p $out/share/vscode
    cp -r VSCode-linux-x64/* $out/share/vscode/

    # Write version file
    echo "${version}" > $out/share/vscode/VERSION
  '';

  meta = with pkgs.lib; {
    description = "Visual Studio Code ${version}";
    # ...
  };
}
```

## Common Pitfalls

## Incorrect

```nix
# ❌ Wrong: Version not used in filename
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-linux-x86_64.tar.gz;  # No version!
  # When you update version, you might forget to check if filename changed
}

# ❌ Wrong: Wrong version in filename
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-1.2.2-linux-x86_64.tar.gz;  # Hardcoded different version!
}
```

## Correct

```nix
# ✅ Correct: Version variable in filename
pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.2.3";
  src = ./myapp-${version}-linux-x86_64.tar.gz;
}
```
