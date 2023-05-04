{ ... }:
{
  # /etc/machine-id is a globally unique identifier used for:
  # - systemd-networkd: DHCP lease renewal (instead of keying by the MAC address)
  # - systemd-journald: to filter logs by host
  # - chromium (potentially to track re-installations)
  # - gdbus; system services that might upgrade to AF_LOCAL if both services can confirm they're on the same machine
  # because of e.g. the chromium use, we *don't want* to persist this.
  # however, `journalctl` won't show logs from previous boots unless the machine-ids match.
  # so for now, generate something unique from the host ssh key.
  # TODO: move this into modules?
  system.activationScripts.machine-id = {
    deps = [ "etc" ];
    text = "sha256sum /etc/ssh/host_keys/ssh_host_ed25519_key | cut -c 1-32 > /etc/machine-id";
  };
}
