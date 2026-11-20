# validationos-vm

A minimal Windows VM for running native Windows builds. It boots Microsoft's
[Validation OS](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/validation-os-overview)
image (a WinPE-like Windows 10/11 environment based on build 26100) under QEMU
with KVM and SSH, adapted from [NixOS/nixpkgs#492435](https://github.com/NixOS/nixpkgs/pull/492435).

The image is patched to start `sshd`, disable the firewall, and authorise the
test SSH key in this directory. `runWithWindowsSsh` boots a fresh copy, waits
for SSH, runs a command, and stops QEMU.

## Building and using it

```sh
# The patched disk image.
nix build .#legacyPackages.x86_64-linux.validationos-vm.validationVhdx

# Boot it, run a command as Administrator, and return its stdout as $out.
nix build --impure --expr \
  '(builtins.getFlake (toString ./.)).legacyPackages.x86_64-linux.validationos-vm.runWithWindowsSsh "windows-version" "$SSH ver > $out"'

cat result
```

SSH listens on `127.0.0.1:2222` as `Administrator`, using
`./test-windows-key`. The key is a disposable test key, not a secret.

The VM needs KVM and boots in roughly 20 seconds. Use the IDE disk (`-hda`, as
the helper does); a virtio disk does not boot this image.

## Guest limitations

Validation OS is much smaller than desktop Windows, and several conveniences
are missing.

### No CA store, so HTTPS fails

Any HTTPS request fails with:

```text
HandshakeFailed (Error_Protocol ("certificate has unknown CA", True, UnknownCa))
```

This affects nova-nix substitutions, `fetchurl` inputs, and anything else
using TLS. `SSL_CERT_FILE` / `NIX_SSL_CERT_FILE` are not honoured by the
Windows TLS stack. The guest has no `certutil` to import certificates either.

Workarounds:

- **Mirror binary caches over plain HTTP.** Run a small reverse proxy on the
  host that forwards to the HTTPS cache, then pass the HTTP URL:

  ```bat
  nova-nix build app.nix --store C:\nix\store ^
    --substituter http://10.0.2.2:8080 ^
    --trusted-key cache.novavero.ai-1:9gQ7tLWMM+2tdC9H5sKMJltDIPfD7X2GWlZe8Aa8hHQ=
  ```

  `10.0.2.2` is the host from QEMU user networking. Cache signatures are still
  verified, so the proxy does not need to be trusted.

- **Serve source tarballs over HTTP.** For a `fetchurl` input, point a test
  copy of the recipe at `http://10.0.2.2:8081/...` and keep the original hash.
  The committed recipes keep their normal HTTPS URLs; this is only a test
  workaround.

- Importing a CA bundle into the Windows certificate store would also work,
  but requires a helper executable because `certutil` is absent.

### nova-nix needs XDG directories

nova-nix calls `getXdgDirectory`, which uses `SHGetFolderPath`. Validation OS
returns `E_NOTIMPL` for that API, so nova-nix exits before parsing arguments:

```text
getXdgDirectory:sHGetFolderPath: illegal operation (unsupported operation)
```

Set the three XDG variables before running it:

```bat
set XDG_CACHE_HOME=C:\xdg\cache
set XDG_CONFIG_HOME=C:\xdg\config
set XDG_DATA_HOME=C:\xdg\data
C:\nova\bin\nova-nix.exe --version
```

Registering the shell folders in the registry does not help; the API itself is
stubbed out.

### Missing tools

The guest has `cmd.exe`, `reg.exe`, OpenSSH and the basic Windows DLLs, but no:

- `tar` — cannot extract `.zip`/`.tar.gz` in the guest
- `powershell`
- `curl`
- `certutil`

Use `scp -r` from the host instead of archiving:

```sh
scp -r -P 2222 -i test-windows-key host-dir/. Administrator@127.0.0.1:C:/target/
```

For anything more complex than a single command, copy a `.bat` file into the
guest and run it with `cmd /c C:\script.bat`; quoting nested `cmd /c` commands
through SSH is error-prone.

### `bash.exe` warns about `/tmp`

MSYS2 programs print:

```text
bash.exe: warning: could not find /tmp, please create!
```

The builds still succeed; the warning is cosmetic.
