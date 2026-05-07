# GitHub Source Builds

Package projects by building from source when no binary releases are available.

## When to Use

- No pre-built binaries available
- Open-source projects with standard build systems
- Need to patch source or customize build

## Go Projects

```nix
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-tool";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  vendorHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  # If no Go modules / vendor directory
  # vendorHash = null;

  meta = with lib; {
    description = "A Go-based CLI tool";
    homepage = "https://github.com/example/my-tool";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
    mainProgram = "my-tool";
  };
}
```

### Getting vendorHash

```bash
# Start with empty hash
vendorHash = "";

# Build, and Nix will error with the correct hash
nix build .#my-tool

# Or set to null if no Go modules
vendorHash = null;
```

### Using a Commit Hash Instead of Version Tag

When a project doesn't use version tags:

```nix
src = fetchFromGitHub {
  owner = "example";
  repo = "my-tool";
  rev = "a1b2c3d4e5f6...";
  hash = "sha256-AAA...";
};

# Override version to use commit date or short hash
version = "0.0.0-git-${builtins.substring 0 7 src.rev}";
```

## Rust Projects

```nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-tool";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  meta = with lib; {
    description = "A Rust-based CLI tool";
    homepage = "https://github.com/example/my-tool";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
    mainProgram = "my-tool";
  };
}
```

### Getting cargoHash

```bash
# Start with empty hash
cargoHash = "";

# Or use fetchCargoGitVendor for more complex cases
# Build and Nix will provide the correct hash
```

## Python Projects

```nix
{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "my-tool";
  version = "1.2.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-tool";
    rev = "v${version}";
    hash = "sha256-AAA...";
  };

  propagatedBuildInputs = with python3Packages; [
    requests
    click
  ];

  meta = with lib; {
    description = "A Python CLI tool";
    homepage = "https://github.com/example/my-tool";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
    mainProgram = "my-tool";
  };
}
```

## C/C++ Projects (CMake)

```nix
{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-tool";
    rev = "v${version}";
    hash = "sha256-AAA...";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A C++ tool";
    homepage = "https://github.com/example/my-tool";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
    mainProgram = "my-tool";
  };
}
```

## Prefetching Source Hashes

```bash
# For a specific version tag
nix store prefetch-file --json "https://github.com/owner/repo/archive/refs/tags/v1.2.3.tar.gz"

# Or use fetchFromGitHub with empty hash and let Nix tell you
# Set: hash = "";
# Then build and copy the expected hash from the error
```

## Strategy Priority

Always check for pre-built binaries before building from source:

1. **Binary releases** (fastest, most reliable) → see [binary-release](binary-release.md)
2. **npm packages with binaries** → see [npm-packaging](npm-packaging.md)
3. **Source build** (this page) → only when no binaries available

Source builds are needed when:
- No binary releases exist
- You need to apply patches
- You need specific compile-time options
- The project is only available as source