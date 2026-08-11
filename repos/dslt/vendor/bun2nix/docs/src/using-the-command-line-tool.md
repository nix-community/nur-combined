# The Command Line Tool

## Recommended Usage

The recommended way to use `bun2nix` is by adding it to your `package.json` to automatically run after any package management option:

```json
"scripts": {
    "postinstall": "bun2nix -o bun.nix"
}
```

However, if you run without the `-o` flag it will produce text output over stdout similar to other `lang2nix` tools. Hence, if you enforce formatting rules in your repository, it is likely a good idea to pass it through a formatter before writing the file.

## Choosing between the WASM CLI and the native CLI

You should use the WASM CLI if you are:

- On a team in environments where Nix may not be installed (i.e. working with Windows users, etc.)
- Not using any exotic dependency types (tarball, git, etc.)

You should use the native CLI if you are:

- All using Nix anyway (less overhead because it is not ran in a JavaScript runtime)
- Using dependency types which require a prefetch (tarball, git, etc.)

## Options

### WASM CLI

Currently, the options available from the web assembly command line tool are as follows:

```
Description
  Convert Bun (v1.2+) packages to Nix expressions

Usage
  $ bun2nix [options]

Options
  -l, --lock-file      The Bun (v1.2+) lockfile to use to produce the Nix expression  (default bun.lock)
  -o, --output-file    The output file to write to - if no file location is provided, print to stdout instead
  -c, --copy-prefix    The prefix to use when copying workspace or file packages  (default ./)
  -v, --version        Displays current version
  -h, --help           Displays this message
```

### Native CLI

Currently, the options available from the native command line tool are as follows:

```
Convert Bun (v1.2+) packages to Nix expressions

Usage: bun2nix [OPTIONS]

Options:
  -l, --lock-file <LOCK_FILE>      The Bun (v1.2+) lockfile to use to produce the Nix expression [default: ./bun.lock]
  -o, --output-file <OUTPUT_FILE>  The output file to write to - if no file location is provided, print to stdout instead
  -c, --copy-prefix <COPY_PREFIX>  The prefix to use when copying workspace or file packages [default: ./]
  -h, --help                       Print help
  -V, --version                    Print version
```
