# Preservation config for ephemeral Protectli router
# Persists state that must survive reboots on a tmpfs root.

{ ... }:

{
  preservation.enable = true;
  preservation.preserveAt."/persistent" = {
    directories = [
      # System state
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log"

      # DHCP leases (kea)
      "/var/lib/kea"

      # SSH host keys
      "/etc/ssh"

      # sops-nix age key
      "/var/lib/sops-nix"
    ];

    files = [
      # Machine ID (for systemd, DHCP, etc.)
      "/etc/machine-id"
    ];

    users.toyvo = {
      directories = [
        ".ssh"
      ];
      files = [
        ".bash_history"
      ];
    };
  };

  # Ensure preserved directories are created with correct permissions
  systemd.tmpfiles.rules = [
    "d /persistent/etc/ssh 0755 root root -"
    "d /persistent/var/lib/kea 0755 kea kea -"
    "d /persistent/var/log 0755 root root -"
    "d /persistent/var/lib/sops-nix 0755 root root -"
  ];
}
