# Nix packaging

These files are MIT licensed (`LICENSE`, here), which is what the NUR asks of
what it evaluates. The agent itself, and the rest of the repository, stay
under the MPL-2.0 at the root.

Three files, for three audiences:

- **`package.nix`** — the derivation.
- **`module.nix`** — the NixOS module, `services.mlos-host-utils`.
- **`nur.nix`** — the entry point the [Nix User Repository][nur] evaluates.

All of them are reachable from the flake at the repository root as well:

```sh
nix run github:MopigamesYT/moonlight-os#mlos-host-utils -- pair
```

## Where this is published

The NUR, not nixpkgs. nixpkgs closed the submission on maturity grounds —
`pkgs/README.md` asks for a project that is established and likely to be
long-lasting — and suggested the NUR in the meantime. That trade is fine:
the NUR takes the package as it is, and it re-evaluates this repository
every few hours instead of needing a reviewed pull request per release.

If the project grows enough for nixpkgs to be worth another try, `package.nix`
is still exactly what `pkgs/by-name/ml/mlos-host-utils/package.nix` would
contain — `passthru.updateScript` and all.

## Using it

Non-flake, in `configuration.nix`:

```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/main.tar.gz") { inherit pkgs; };
  };

  imports = [ pkgs.nur.repos.mopigamesyt.modules.mlos-host-utils ];

  services.mlos-host-utils = {
    enable = true;
    openFirewall = true;   # off by default; see below
  };
}
```

With flakes, take `nur.url = "github:nix-community/NUR"` as an input and
import `nur.legacyPackages.${system}.repos.mopigamesyt.modules.mlos-host-utils`.
Or skip the NUR entirely and use this flake directly:

```nix
{
  inputs.moonlight-os.url = "github:MopigamesYT/moonlight-os";

  # in configuration.nix
  imports = [ inputs.moonlight-os.nixosModules.default ];
}
```

Either way you get the agent at boot with the right `usbip` on its path,
`vhci-hcd` loaded, and the pairing code kept in `/var/lib/mlos-host-utils`.

## On NixOS, use the module

`mlos-host-utils install` is the wrong command here. It installs a usbip
package with the system package manager, writes a unit into
`/etc/systemd/system` and edits the firewall — and a `nixos-rebuild switch`
takes back the parts NixOS considers its own. The binary knows it is on
NixOS and says so rather than doing half of it.

`MLOS_HOST_UTILS_DIR` is set system-wide as well as on the unit, deliberately:
the agent and the CLI have to read the same state directory, and if they do
not, `mlos-host-utils pair` mints a *second* token and prints a code the
running agent will reject — with nothing on screen to suggest why.

`openFirewall` defaults to false. Anything that can reach the port and has
the pairing code can attach USB devices from its own machine to this one, so
opening it is a decision rather than a default.

## Registering with the NUR (once)

A pull request against [nix-community/NUR][nur] adding this to `repos.json`:

```json
"mopigamesyt": {
  "url": "https://github.com/MopigamesYT/moonlight-os",
  "file": "packaging/nix/nur.nix"
}
```

`file` is what keeps this out of a second repository: NUR defaults to
`default.nix` at the root, and the root of this one is an ISO build.

After that there is nothing to do per release. NUR re-evaluates the default
branch on a schedule, so a release reaches users as soon as the version bump
lands on `main`.

## Per-release bumps

CI does this: the `nix` job in `.github/workflows/host-utils.yml` runs
`update.sh` on every tag and commits the result back to `main`, which is what
the NUR then picks up. Locally the same thing is:

```sh
./update.sh v0.1.3          # rewrites version and hash, needs nix
```

The hash `fetchFromGitHub` wants is of the unpacked tree, not of a tarball,
so unlike the AUR and winget checksums it cannot be worked out with
`sha256sum` — it comes from `nix flake prefetch`.

[nur]: https://github.com/nix-community/NUR
