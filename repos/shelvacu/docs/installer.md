# Installer media

Prepare an ISO or USB with the installer SSH CA:

```sh
nix run .#make-installer -- iso installer.iso --principals vacuInstaller,installer.example.com
sudo nix run .#make-installer -- usb /dev/sdX --yes --principals vacuInstaller,192.0.2.10
```

USB mode erases the whole device. It rejects mounted filesystems and partitions.
If root cannot decrypt SOPS, prepare an ISO as your user, then write it with
`sudo dd if=installer.iso of=/dev/sdX bs=4M conv=fsync status=progress`.

The script decrypts `secrets/misc/installer_ssh_ca` as binary using wrapped SOPS,
or accepts `--ca-key /path/to/decrypted/key`. It verifies the CA against
`temp_installer_ssh_ca.pub` and appends it and the signing settings to the initrd
outside the Nix store. The ISO is packed once from Nix-built boot files and
SquashFS. ISO files have private permissions.

At each boot the installer generates a fresh Ed25519 SSH host key, signs it with
the embedded CA, and prints the public key and SHA256 fingerprint to the console.
The key lives in `/run` and changes on reboot. SSH requires successful signing.
Certificates last 52 weeks from boot by default; override with `--validity`
(ssh-keygen syntax). No extra RNG seed is embedded.

List every hostname or IP used to connect in `--principals`; hostnames are
normalized to lowercase for SSH matching. Compare the console
fingerprint with the SSH client's fingerprint, or trust `temp_installer_ssh_ca.pub`
for the intended names using an `@cert-authority` known_hosts entry:

```text
@cert-authority installer.example.com ssh-ed25519 ...
```

Anyone who reads the prepared media can extract the CA and impersonate installers
when using CA verification. Console fingerprint verification remains independent
of that CA. Raw Nix build outputs lack the CA and cannot start SSH successfully.

## PXE

```sh
nix run .#make-installer -- pxe --principals vacuInstaller,192.0.2.10
```

This serves the kernel and CA-bearing initrd through Pixiecore, including its
ProxyDHCP, TFTP, and HTTP servers. Keep the LAN's existing DHCP server running.
The command decrypts the CA as your user, then uses sudo to start a transient
systemd service. It needs a Linux host running systemd.

To boot Memtest86+ instead of the installer:

```sh
nix run .#make-installer -- pxe --memtest
```

This serves Memtest86+ without an initrd and does not decrypt or embed the SSH CA.
The same firewall, port, and listen-address options apply.

On a NixOS host it detects the nftables or iptables firewall and offers to open
UDP 67, 69, 4011 and the HTTP TCP port temporarily. Use `--firewall open` to accept
without a prompt, or `--firewall skip` to manage the firewall yourself. Each run
adds one jump to its own `temp-vacu-make-installer-$PID` chain
(`temp-vacu-installer-$PID` with iptables due to its chain name limit). That chain
allows all required ports, even if other rules already allow them. It removes
only its own rules when the server stops, fails, or is killed. Press Ctrl-C to
stop serving and clean up. If the launcher is killed with SIGKILL, the service
keeps running; stop the `installer-pxe-….service` unit printed at startup with
`sudo systemctl stop UNIT`.

HTTP defaults to port 8080; change it with `--port`. Use `--listen-addr ADDRESS`
to select the server's IPv4 address. Pixiecore logs boot requests and transfers
to the terminal. Anyone able to download or capture the initrd can obtain the CA.
