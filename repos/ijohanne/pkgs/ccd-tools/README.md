# ccd-tools

Rust tools for Concordium accounts, built and maintained in this repository.
The first binary is `ccd-status`; additional commands can go in `src/src/bin/`
and share the library's account configuration and CCDExplorer client.

## Account file

Pass a CSV file with `Name,Address` records. The header is optional. Use full
50-character Concordium mainnet addresses or numeric account indices. Quote
names containing commas using standard CSV quoting. Blank lines are ignored.

```csv
Name,Address
Savings,3d4tsSiBrJXn2aiNHdfqMq2b9oGttoKn2LDCZbHHMm1WZi2c95
Another account,76937
```

```console
ccd-status --accounts /path/to/accounts.csv
```

Or set `CCD_TOOLS_ACCOUNTS` to the filename. `--accounts` takes precedence.
`--accounts -` reads stdin, including decrypted output piped from SOPS:

```fish
sops --decrypt accounts.csv.enc | ccd-status --accounts -
```

The report uses the machine's local date and preserves CSV order:

```text
CCD Status Report 04/11/2026:
Savings, staked 47m, available 342.46k
Another account, staked 45.46m, available 5.05m
```

Amounts are CCD, rounded to at most two decimal places with `k`, `m`, `b`, or
`t` suffixes. Nonzero amounts below 0.01 CCD are shown as `<0.01`.
Available means **account balance minus own stake/delegated stake**. This is
not necessarily spendable balance when funds are locked or in cooldown.
The tool reads the public CCDExplorer mainnet account pages and, for validators,
the separately loaded validator details. CCDExplorer currently rounds stake
to whole CCD in those details; reported amounts inherit that source precision.
It never uses the pool's total stake as the account's own stake.

Invalid configuration, HTTP failures, missing balance/stake fields, and
inconsistent balances produce an error on stderr and a nonzero exit status.
A report is printed only after every lookup succeeds. Each HTTP request has a
30-second timeout. Secret CSV contents are read only at runtime.

## Home Manager and sops-nix

Import the flake's Home Manager module and point it at the decrypted secret:

```nix
{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.nur-packages.lib.homeManagerModules.ccd-tools ];

  sops.secrets.ccd-accounts = {
    sopsFile = ./accounts.csv.enc;
    format = "binary";
  };

  programs.ccd-tools = {
    enable = true;
    package = inputs.nur-packages.legacyPackages.${pkgs.stdenv.hostPlatform.system}.ccd-tools;
    accountsFile = config.sops.secrets.ccd-accounts.path;
  };
}
```

This assumes sops-nix is already configured with a decryption key. Binary
format lets SOPS encrypt the CSV verbatim. A YAML secret whose value is CSV
works as well; point `accountsFile` at that decrypted secret's `.path`.

You can now run `ccd-status` with no arguments. Every binary in `ccd-tools`
is wrapped with the same `CCD_TOOLS_ACCOUNTS` default, so future commands inherit
the configuration. An existing environment variable or `--accounts` overrides
the wrapper default. Only the runtime path is stored in the wrapper; the file
need not exist during evaluation or build and its contents stay out of the Nix
store. Pass a string path, not a Nix path literal to a plaintext file.

For non-flake use, import `home-manager/ccd-tools.nix` from this repository.
The module's package defaults to the local package, so `package` is optional.

## Development

From the repository root:

```fish
nix develop
cargo test --manifest-path pkgs/ccd-tools/src/Cargo.toml
cargo clippy --manifest-path pkgs/ccd-tools/src/Cargo.toml --all-targets -- -D warnings
nix build .#ccd-tools
nix run .#ccd-tools -- --accounts /path/to/accounts.csv
```

Tests use minimal HTML fixtures based on CCDExplorer pages and do not need
network access. The Nix package runs these tests during its build.
