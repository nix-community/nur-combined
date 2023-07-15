## to add a new network
- connect to it
  - iwd: `iwctl`
  - networkmanager:`nmtui`
- find it under:
  - iwd: `/var/lib/iwd`
  - networkmanager: `/var/lib/NetworkManager/system-connections`
  - networkmanager (new install): `/etc/NetworkManager/system-connections`
- `sops all.json` and add an entry with the ssid and passphrase
