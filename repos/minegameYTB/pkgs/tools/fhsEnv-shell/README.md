# fhsEnv-shell

A multi-platform FHS-compatible development environment for Linux kernel, Buildroot, and packaging tooling.

## Usage

### Basic

```bash
nix run "github:minegameYTB/nurpkgs-repo#dev.fhsEnv-shell"
```

### Pre-built variants

| Variant | Command |
|---|---|
| Default | `nix run ".#dev.fhsEnv-shell"` |
| With clang | `nix run ".#dev.fhsEnv-shell-clang"` |
| + kernel-tools | `nix run ".#dev.fhsEnv-shell-krnl"` |
| + buildroot-tools | `nix run ".#dev.fhsEnv-shell-buildroot"` |
| + debian-tools | `nix run ".#dev.fhsEnv-shell-deb-tools"` |
| + redhat-tools | `nix run ".#dev.fhsEnv-shell-rh-tools"` |
| All features | `nix run ".#dev.fhsEnv-shell-all-specific"` |
| All (no kernel) | `nix run ".#dev.fhsEnv-shell-all-specific-nokrnl"` |

## Options

### `kernel-tools` (default: `false`)

Adds kernel build dependencies (Qt5 for `xconfig`, libcap-ng, pciutils, syslinux, cdrkit, OpenSSL/ncurses headers) and sets `PKG_CONFIG_PATH`, `CFLAGS`, `LDFLAGS` for zlib and elfutils.

Note: boot image targets (`isoimage`, `hdimage`, `fdimage`, `bzdisk`) are x86-only. The package enforces this with a build-time assertion on non-x86 platforms. Use `extraPkgs` to add custom ISO creation tools on other architectures.

### `useClang` (default: `false`)

Use clang/LLVM instead of gcc. Adds `lld`, `llvm`, and `clang-manpages`. Sets `CC=clang`, `LD=ld.lld`, `AR=llvm-ar`, `NM=llvm-nm`, etc. in the environment.

When combined with `kernel-tools`, uses `clang.cc` (unwrapped) to avoid nixpkgs wrapper flag injection that conflicts with kernel build flags.

### `buildroot-tools` (default: `false`)

Adds Buildroot-specific dependencies (patchutils, swig, gperf, libtool, libmpc, elf, mpfr, gmp).

### `debian-tools` (default: `false`)

Adds `dpkg` and `glibc.dev`.

### `redhat-tools` (default: `false`)

Adds `rpm`.

### `extraPkgs` (default: `[]`)

Extra packages to include. Can be a list `[ pkgs.hello ]` or a function `pkgs: [ pkgs.hello ]`.

### `extraInitCommands` (default: `""`)

Shell commands to run at environment startup (before the prompt is set).

### `extraBwrapArgs` (default: `[]`)

Extra arguments passed directly to bubblewrap (bwrap). Useful for mounting tmpfs, bind-mounting host paths, or adjusting container isolation.

```nix
extraBwrapArgs = [ "--tmpfs" "/mnt/cache" ];
```

Note: `--bind` requires the target path to already exist inside the FHS env; use `--tmpfs` for new directories.

## Examples

### Custom FHS env

```nix
# In your flake or pkgs/default.nix
fhsEnv-shell-custom = callPackage ./tools/fhsEnv-shell {
  extraPkgs = pkgs: with pkgs; [ docker ripgrep jq ];
  extraInitCommands = ''
    alias ll='ls -la'
    alias gs='git status'
  '';
};
```

### Kernel compilation with gcc

```bash
fhsEnv-shell-krnl
cd /path/to/linux
make tinyconfig && make -j$(nproc)
```

### Kernel compilation with clang

When using `useClang + kernel-tools`, the environment provides `CC=clang` and LLVM tools (`ld.lld`, `llvm-ar`, etc.) via environment variables.

```bash
fhsEnv-shell-clang-krnl   # or override { useClang = true; kernel-tools = true; }
cd /path/to/linux
make tinyconfig && make -j$(nproc)
```

The `make` wrapper injects `CC=clang` automatically to override the kernel Makefile's `CC = gcc` (line 535). Host tools (fixdep, etc.) use gcc via `HOSTCC` (unchanged from `stdenv.cc`).

### Buildroot

```bash
fhsEnv-shell-buildroot
cd /path/to/buildroot
make qemu_x86_64_defconfig
make
```

### Deb packaging

```bash
fhsEnv-shell-deb-tools
cd /path/to/sources
dpkg-buildpackage -us -uc
```

## Implementation notes

- Uses `buildFHSEnv` under the hood
- Kernel Makefile explicitly sets `CC = $(CROSS_COMPILE)gcc` — a `make` wrapper injects `CC=clang` when `useClang` is enabled
- Clang-unwrapped (`clang.cc`) is used for kernel builds to avoid nixpkgs wrapper injecting `NIX_CFLAGS_COMPILE`, which conflicts with `-nostdlibinc` + `-Werror=unused-command-line-argument`
- `LLVM=1` is intentionally NOT set because it would override `HOSTCC=clang`, breaking host tool compilation — individual env vars are used instead
