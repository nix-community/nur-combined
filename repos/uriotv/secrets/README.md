# Local Cachix credentials with sops-nix

This directory is for the **encrypted** local publication token. GitHub Actions
continues using its existing `CACHIX_AUTH_TOKEN` repository secret; this file is
for a desktop/local build and is independent of that secret.

No real token, age recipient or private key is provided by this repository.
Do not paste token values into Nix expressions, command arguments, chat or a
plaintext file in this Git tree. Flake source files may be copied to /nix/store.

## 1. Supply public recipients

```console
nix develop
cp .sops.yaml.example .sops.yaml
$EDITOR .sops.yaml
```

Replace BOTH example public age recipients. One can be your existing personal
SOPS recipient; the other must be a recipient that **sops-nix on the target
desktop** can decrypt. If both use the same key, one recipient is sufficient.
Reuse the computer's existing SOPS configuration rather than generating or
replacing host keys. An editor's `SOPS_AGE_KEY_CMD` is not automatically available
to NixOS activation: the desktop must also have a configured host age/SSH key.

Only PUBLIC recipients belong in `.sops.yaml`. Private age keys stay outside Git
and /nix/store. You can find the public recipient of an existing age key using
`age-keygen -y /path/to/private-age-key`, or follow your existing SOPS setup.

## 2. Enter the token in the SOPS editor

Get a Cachix token with write permission for `uriotv` from the Cachix dashboard.
GitHub cannot return the value of a previously saved Actions Secret.

From the repository root:

```console
sops secrets/cachix.yaml
```

Inside the SOPS editor, replace the sample document with this key and your real
value (do not use the placeholder literally):

```yaml
cachix_auth_token: <your-Cachix-write-token>
```

Save and close. SOPS encrypts the values before saving the file in this
repository. Never copy the plaintext `.example` to `cachix.yaml` and commit it.
Before staging, run:

```console
python3 tests/repo-secrets.py
git add .sops.yaml secrets/cachix.yaml
```

The guard checks for SOPS ciphertext and rejects plaintext/placeholders; it does
not cryptographically prove that the recipients/MAC are valid. Test decryption
locally through your normal SOPS workflow without printing the token to logs.
The encrypted file must be Git-visible before a flake can include it.

## 3. Provision the token on your desktop

In the target NixOS configuration, import the optional module and select the
existing local user. This does NOT enable or change the kernel:

```nix
{ inputs, ... }:
{
  imports = [ inputs.urio-nur.nixosModules.kernel-publisher ];
  services.urioNur.kernelPublisher = {
    enable = true;
    user = "urio"; # existing user that runs nix run
    sopsFile = inputs.urio-nur + "/secrets/cachix.yaml";
  };

  # Only if not already configured by your host's sops-nix setup:
  # sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}
```

If your NixOS configuration already imports sops-nix, instead import
`inputs.urio-nur.nixosModules.kernel-publisher-options`. That exports only our
options/declaration, avoiding a second independent sops-nix module version.

The module requires an existing user and explicit encrypted `sopsFile`.
It declares the YAML key `cachix_auth_token` as
`/run/secrets/cachix_auth_token`, owned by that user, mode **0400**. It does not
set global `sops.defaultSopsFile` or change existing age/SSH/GPG key settings.
Other secrets remain untouched. Missing/wrong decryption keys or an invalid
ciphertext cause sops-nix provisioning to fail, not a plaintext fallback.

Update the `urio-nur` input in your desktop configuration after the encrypted
file and modules are available remotely. YOU activate the NixOS configuration
(e.g. `nh os switch .` in nix-config). This repository does not perform the switch.
No automatic privilege escalation is used by the local build command.

## 4. Build and publish

After activation, no token arguments are needed:

```console
nix run github:urioTV/urio-nur#build-and-cache-kernel
```

Or from this checkout: `nix run .#build-and-cache-kernel`.
The command discovers the decrypted runtime file automatically. Without a
readable token it stops before starting the expensive build; `--build-only`
never needs one. A differently pinned repo may select a different kernel, so
use the same revision as CI when populating its cache.

For key rotation, edit the encrypted file with `sops`, commit it, update the
input and reactivate. After changing recipient keys in `.sops.yaml`, use
`sops updatekeys secrets/cachix.yaml` and verify the desktop still has access.
