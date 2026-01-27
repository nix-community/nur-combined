# NUR Package Repository

This repository contains Nix packages for the [Nix User Repository (NUR)](https://github.com/nix-community/NUR).

## Packages

- **lazymake** - Modern TUI for Makefiles with interactive target selection and dependency visualization

## Installation

### Using with NUR

Add this repository to your NUR configuration and then install packages as usual:

```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

### Direct Installation

You can install packages directly:

```bash
nix-env -f default.nix -iA lazymake
```

Or with flakes:

```bash
nix profile install .#lazymake
```

## Building Locally

```bash
nix-build -A lazymake
```

## Testing

Test the package build:

```bash
nix-build -A lazymake
./result/bin/lazymake --help
```

## Package Details

### lazymake

A terminal user interface for browsing and running Makefile targets.

**Features:**
- Fuzzy search for Makefile targets
- Execution history tracking
- Dependency graph visualization
- Variable inspection
- Syntax highlighting
- Safety warnings for dangerous commands
- Performance tracking

**Version:** 0.2.0  
**License:** MIT  
**Homepage:** https://github.com/rshelekhov/lazymake

## Contributing

Contributions are welcome! Please ensure all packages:

1. Build successfully with `nix-build`
2. Follow Nixpkgs conventions
3. Include proper metadata (description, license, maintainers, etc.)
4. Are tested before submission

## Submitting to NUR

To submit this repository to NUR:

1. Push this repository to GitHub
2. Fork the [NUR repository](https://github.com/nix-community/NUR)
3. Add your repository to `repos.json`:
   ```json
   {
     "your-github-username": {
       "url": "https://github.com/your-github-username/nur-packages"
     }
   }
   ```
4. Submit a pull request

See the [NUR documentation](https://github.com/nix-community/NUR#how-to-add-your-own-repository) for more details.
